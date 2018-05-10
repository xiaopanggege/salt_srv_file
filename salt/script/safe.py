import os
import socket
import re
import sys

reload(sys)
sys.setdefaultencoding('utf8')

SecResultFileDir = r'C:\Scripts\safe'
SecResultFileName = SecResultFileDir+'\SecResultFile.txt'

ItemList1=['PasswordComplexity','MinimumPasswordLength','PasswordHistorySize','ClearTextPassword','MaximumPasswordAge','MinimumPasswordAge','LockoutBadCount','ResetLockoutCount']
ItemList2=['LockoutDuration','ShutdownWithoutLogon','DontDisplayLastUserName','EnableForcedLogOff','RestrictAnonymousSAM','RestrictAnonymous','ClearPageFileAtShutdown','AuditSystemEvents']
ItemList3=['AuditObjectAccess','AuditPrivilegeUse','AuditPolicyChange','AuditAccountManage','AuditLogonEvents','AuditAccountLogon','FullPrivilegeAuditing','DisableCAD']
ItemList4=['RestrictNullSessAccess','NoDriveTypeAutoRun','SeRemoteShutdownPrivilege','SeRemoteInteractiveLogonRight','EnableGuestAccount','AutoAdminLogon'] 
ItemList=ItemList1+ItemList2+ItemList3+ItemList4

HostName=socket.gethostbyname_ex(socket.gethostname())[0]
IpAddress=socket.gethostbyname_ex(socket.gethostname())[2]

def ExportSecResultFile():  # Dump Policy list
    if os.path.exists(SecResultFileName):
        os.remove(SecResultFileName)
    elif os.path.exists(SecResultFileDir) is False:
        os.system('mkdir %s' %SecResultFileDir)
    os.system("secedit /export /cfg %s >nul"%SecResultFileName)

def ChangeEncodeUTF8(FilePath):   # SecResultFile recode UTF-8
    FileObject = open(FilePath,'r+')
    FileText = FileObject.read()
    FileTextUTF8 = FileText.decode('UTF-16LE').encode('UTF-8')
    FileObject.close()    
    FileObject = open('%s' %FilePath,'w+')
    FileObject.write(u'%s' %FileTextUTF8)
    FileObject.close()
    
def StrExchangeCodeUTF8(Text,CodeType):
    TextUTF8Type = Text.decode(CodeType).encode('UTF-8')
    return(TextUTF8Type)

def FormatData(FilePath):
    FileObject = open(FilePath,'r')
    FileLine = FileObject.readline().strip('\n')
    ResultDataList=[]
    while FileLine:
        for Item in ItemList:
            if FileLine.find(Item) <> -1:
                if FileLine.find('MACHINE') == 0:
                    ResultDataList.append(FormatRegPolicyData(FileLine))    
                else:
                    ResultDataList.append(FormatGroupPolicyData(FileLine))
        FileLine = FileObject.readline().strip('\n')
    FileObject.close()
    return(ResultDataList)

def FormatGroupPolicyData(GroupLineData):
    GroupLineDataList=GroupLineData.replace('\r','').split(' = ')
    GroupLineDataList=IpAddress+GroupLineDataList
    return(GroupLineDataList)

def FormatRegPolicyData(RegLineData):
    RegLineDataList=RegLineData.replace('\r','').split('=')
    RegLineDataList=IpAddress+RegLineDataList
    return(RegLineDataList)
    
def NetShareJudge():
    Resp = os.popen("net share").read()
    RespList =  StrExchangeCodeUTF8(Resp,'GB2312').split('\n')
    for StrLine in RespList:
        if StrLine.find('默认') >= 0:
            NetShareStatus = IpAddress + ['Net Share','NotSafe']
            break
        else:
            NetShareStatus = IpAddress + ['Net Share','NotSafe']
    return(NetShareStatus)
    
def main():
    ExportSecResultFile()
    ChangeEncodeUTF8(SecResultFileName)
    ResultList = []
    ResultList = ResultList + FormatData(SecResultFileName)
    ResultList.append(NetShareJudge())
    print(ResultList)
    
if __name__=='__main__':
    main()

