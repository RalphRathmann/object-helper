   PROGRAM



   INCLUDE('ABERROR.INC'),ONCE
   INCLUDE('ABFILE.INC'),ONCE
   INCLUDE('ABUTIL.INC'),ONCE
   INCLUDE('ERRORS.CLW'),ONCE
   INCLUDE('KEYCODES.CLW'),ONCE
   INCLUDE('ABFUZZY.INC'),ONCE
   INCLUDE('WINEXT.INC'),ONCE

   MAP
     MODULE('OBJECTHELPER_BC.CLW')
DctInit     PROCEDURE                                      ! Initializes the dictionary definition module
DctKill     PROCEDURE                                      ! Kills the dictionary definition module
     END
!--- Application Global and Exported Procedure Definitions --------------------------------------------
     MODULE('OBJECTHELPER001.CLW')
Main                   PROCEDURE   !Wizard Application for C:\Projekte\ObjectHelper\OH.dct
     END
     CleanCloseDown()
   END

testmessage          CSTRING(10000)
glo:messagethread    LONG
glo:messagestring    CSTRING(100000)
glo:messagewindowopen BYTE
glo:depth            LONG
sic:line             CSTRING(255)
sic:depth            LONG
sic:filenr           LONG
MemQueue             QUEUE,PRE(MQ)
Line                   CSTRING(255)
depth                  LONG
Filenr                 LONG
                     END
activeProject        LONG
activeProjectName    STRING(80)
SilentRunning        BYTE(0)                               ! Set true when application is running in 'silent mode'

!region File Declaration
Settings             FILE,DRIVER('TOPSPEED'),PRE(Set),CREATE,BINDABLE,THREAD !Einstellungen       
NrKey                    KEY(Set:Nr),NOCASE,PRIMARY        !                    
NameKey                  KEY(Set:Name),NOCASE              !                    
Record                   RECORD,PRE()
Nr                          LONG                           !                    
Name                        STRING(60)                     !Name of Field       
Type                        LONG                           !Value|String|Bool|Date
Content                     CSTRING(255)                   !of the Entry        
                         END
                     END                       

Projects             FILE,DRIVER('TOPSPEED'),PRE(Pro),CREATE,BINDABLE,THREAD !for Multi-Projects  
NrKey                    KEY(Pro:Nr),NOCASE,PRIMARY        !                    
NameKey                  KEY(Pro:Name),NOCASE              !                    
Record                   RECORD,PRE()
Nr                          LONG                           !                    
Name                        STRING(60)                     !Name of Field       
Description                 CSTRING(255)                   !of Project          
Startfile                   STRING(255)                    !without path        
Types                       STRING(20)                     !allowed Extensions Filetype
                         END
                     END                       

Files                FILE,DRIVER('TOPSPEED'),PRE(Files),CREATE,BINDABLE,THREAD !of Project          
NrKey                    KEY(Files:Nr),NOCASE,PRIMARY      !                    
ProNrKey                 KEY(Files:ProNr),DUP,NOCASE       !                    
PathnumKey               KEY(Files:Pathnum),DUP,NOCASE,OPT !                    
FilenameKey              KEY(Files:Filename),DUP,NOCASE    !                    
Record                   RECORD,PRE()
Nr                          LONG                           !                    
ProNr                       LONG                           !                    
Pathnum                     LONG                           !Path 1. portion as of paths
Pathpt2                     STRING(255)                    !Path of File pt2    
Filename                    STRING(60)                     !without path        
Type                        STRING(12)                     !Extension Filetype  
                         END
                     END                       

Paths                FILE,DRIVER('TOPSPEED'),PRE(Pat),CREATE,BINDABLE,THREAD !of Project          
NrKey                    KEY(Pat:Nr),NOCASE,PRIMARY        !                    
NameKey                  KEY(Pat:ProNr,Pat:LookupPath),NOCASE !ProNr and Path      
ProNrKey                 KEY(Pat:ProNr),DUP,NOCASE         !                    
Record                   RECORD,PRE()
Nr                          LONG                           !                    
ProNr                       LONG                           !                    
LookupPath                  CSTRING(255)                   !Path to lookup in   
Subdirs                     BYTE                           !search subs?        
                         END
                     END                       

Includes             FILE,DRIVER('TOPSPEED'),PRE(Incl),CREATE,BINDABLE,THREAD !#included files of project
NrKey                    KEY(Incl:Nr),NOCASE,PRIMARY       !                    
FilenameNrKey            KEY(Incl:FilenameNr),DUP,NOCASE   !Nr in Files         
Record                   RECORD,PRE()
Nr                          LONG                           !                    
FilenameNr                  LONG                           !included FilenameNr in Files
Level                       LONG                           !depth 1=root of Project
included_filenr             LONG                           !Name of Included-File
                         END
                     END                       

ASCIIFile            FILE,DRIVER('ASCII'),PRE(ASC),BINDABLE,THREAD !read the files      
Record                   RECORD,PRE()
Line                        STRING(255)                    !                    
                         END
                     END                       

!endregion


!// List Format Manager declaration -------------------------------------START-

LFM_CFile            FILE,PRE(CFG),CREATE,DRIVER('TopSpeed'),THREAD,NAME('Formats.FDB')
key_Main               KEY(+CFG:AppName,+CFG:ProcId,+CFG:UserId,+CFG:CtrlId,+CFG:FormatId),OPT,NOCASE
Record                 RECORD,PRE()
AppName                  STRING(30)                        ! Procedure identifier
ProcId                   STRING(30)                        ! Procedure identifier
UserId                   SHORT                             ! User identifier
CtrlId                   SHORT                             ! Control identifier
FormatId                 SHORT                             ! Format identifier
FormatName               STRING(30)                        ! Format name
Flag                     BYTE                              ! Default/current flag
Format                   STRING(5120)                      ! Format buffer
VarLine                  STRING(2048)                      ! Variable buffer
                       END
                     END

!// List Format Manager declaration ---------------------------------------END-
GLO:CleanCloseDown           BYTE(0)
GLO:CleanCloseDownMainThread LONG
NOTIFY:CloseDown             EQUATE(EVENT:CloseDown)
GlobalFrameExtension WindowExtenderClass                   ! Global FrameExtension Manager
Access:Settings      &FileManager,THREAD                   ! FileManager for Settings
Relate:Settings      &RelationManager,THREAD               ! RelationManager for Settings
Access:Projects      &FileManager,THREAD                   ! FileManager for Projects
Relate:Projects      &RelationManager,THREAD               ! RelationManager for Projects
Access:Files         &FileManager,THREAD                   ! FileManager for Files
Relate:Files         &RelationManager,THREAD               ! RelationManager for Files
Access:Paths         &FileManager,THREAD                   ! FileManager for Paths
Relate:Paths         &RelationManager,THREAD               ! RelationManager for Paths
Access:Includes      &FileManager,THREAD                   ! FileManager for Includes
Relate:Includes      &RelationManager,THREAD               ! RelationManager for Includes
Access:ASCIIFile     &FileManager,THREAD                   ! FileManager for ASCIIFile
Relate:ASCIIFile     &RelationManager,THREAD               ! RelationManager for ASCIIFile

FuzzyMatcher         FuzzyClass                            ! Global fuzzy matcher
GlobalErrorStatus    ErrorStatusClass,THREAD
GlobalErrors         ErrorClass                            ! Global error manager
INIMgr               INIClass                              ! Global non-volatile storage manager
GlobalRequest        BYTE(0),THREAD                        ! Set when a browse calls a form, to let it know action to perform
GlobalResponse       BYTE(0),THREAD                        ! Set to the response from the form
VCRRequest           LONG(0),THREAD                        ! Set to the request from the VCR buttons

Dictionary           CLASS,THREAD
Construct              PROCEDURE
Destruct               PROCEDURE
                     END


  CODE
  IF GlobalFrameExtension.RestoreInstanceRunning()
     HALT()
  END
  GlobalErrors.Init(GlobalErrorStatus)
  FuzzyMatcher.Init                                        ! Initilaize the browse 'fuzzy matcher'
  FuzzyMatcher.SetOption(MatchOption:NoCase, 1)            ! Configure case matching
  FuzzyMatcher.SetOption(MatchOption:WordOnly, 0)          ! Configure 'word only' matching
  INIMgr.Init('.\ObjectHelper.INI', NVD_INI)               ! Configure INIManager to use INI file
  DctInit
  Main
  INIMgr.Update
  INIMgr.Kill                                              ! Destroy INI manager
  FuzzyMatcher.Kill                                        ! Destroy fuzzy matcher
    
CleanCloseDown  PROCEDURE()
 CODE
 GLO:CleanCloseDown = True
 NOTIFY(NOTIFY:CloseDown,GLO:CleanCloseDownMainThread)


Dictionary.Construct PROCEDURE

  CODE
  IF THREAD()<>1
     DctInit()
  END


Dictionary.Destruct PROCEDURE

  CODE
  DctKill()

