

   MEMBER('ObjectHelper.clw')                              ! This is a MEMBER module


   INCLUDE('ABBROWSE.INC'),ONCE
   INCLUDE('ABPOPUP.INC'),ONCE
   INCLUDE('ABRESIZE.INC'),ONCE
   INCLUDE('ABTOOLBA.INC'),ONCE
   INCLUDE('ABWINDOW.INC'),ONCE
   INCLUDE('BRWEXT.INC'),ONCE

                     MAP
                       INCLUDE('OBJECTHELPER002.INC'),ONCE        !Local module procedure declarations
                       INCLUDE('OBJECTHELPER001.INC'),ONCE        !Req'd for module callout resolution
                     END


!!! <summary>
!!! Generated from procedure template - Window
!!! Settings
!!! </summary>
UpdateSettings PROCEDURE 

CurrentTab           STRING(80)                            !
ActionMessage        CSTRING(40)                           !
History::Set:Record  LIKE(Set:RECORD),THREAD
QuickWindow          WINDOW('Settings'),AT(,,358,164),FONT('Microsoft Sans Serif',8,,FONT:regular,CHARSET:DEFAULT), |
  RESIZE,CENTER,GRAY,IMM,MDI,HLP('UpdateSettings'),SYSTEM
                       SHEET,AT(4,4,350,140),USE(?CurrentTab)
                         TAB('&1) '),USE(?Tab:1)
                           PROMPT('Nr:'),AT(8,20),USE(?Set:Nr:Prompt),TRN
                           ENTRY(@n_4),AT(61,20,24,10),USE(Set:Nr),RIGHT(1),DISABLE,READONLY,SKIP
                           PROMPT('Name:'),AT(8,34),USE(?Set:Name:Prompt),TRN
                           ENTRY(@s60),AT(61,34,244,10),USE(Set:Name),MSG('Name of Field'),TIP('Name of Field')
                           OPTION('Type:'),AT(61,83,217,29),USE(Set:Type),BOXED,MSG('Value|String|Bool|Date'),TIP('Value|Stri' & |
  'ng|Bool|Date'),TRN
                             RADIO('Value'),AT(65,93),USE(?Set:Type:Radio1),TRN,VALUE('1')
                             RADIO('String'),AT(114,93),USE(?Set:Type:Radio2),TRN,VALUE('2')
                             RADIO('Bool'),AT(165,93),USE(?Set:Type:Radio3),TRN,VALUE('3')
                             RADIO('Date'),AT(214,93),USE(?Set:Type:Radio4),TRN,VALUE('4')
                           END
                           PROMPT('Content:'),AT(8,60),USE(?Set:Content:Prompt),TRN
                           ENTRY(@s254),AT(61,60,280,10),USE(Set:Content),MSG('of the Entry'),TIP('of the Entry')
                         END
                       END
                       BUTTON('&OK'),AT(252,147,50,15),USE(?OK),LEFT,ICON('WAOK.ICO'),DEFAULT,FLAT,TIP('Änderungen' & |
  ' übernehmen')
                       BUTTON('&Close'),AT(306,147,50,15),USE(?Cancel),LEFT,ICON('WACANCEL.ICO'),FLAT,MSG('Fenster sc' & |
  'hliessen ohne Speichern'),TIP('Fenster schliessen ohne Speichern')
                       BUTTON('&Help'),AT(2,147,50,15),USE(?Help),LEFT,ICON('WAHELP.ICO'),FLAT,HIDE,MSG('See Help Window'), |
  STD(STD:Help),TIP('See Help Window')
                     END

ThisWindow           CLASS(WindowManager)
Ask                    PROCEDURE(),DERIVED
Init                   PROCEDURE(),BYTE,PROC,DERIVED
Kill                   PROCEDURE(),BYTE,PROC,DERIVED
Run                    PROCEDURE(),BYTE,PROC,DERIVED
TakeAccepted           PROCEDURE(),BYTE,PROC,DERIVED
TakeWindowEvent        PROCEDURE(),BYTE,PROC,DERIVED
                     END

Toolbar              ToolbarClass
Resizer              CLASS(WindowResizeClass)
Init                   PROCEDURE(BYTE AppStrategy=AppStrategy:Resize,BYTE SetWindowMinSize=False,BYTE SetWindowMaxSize=False)
                     END

CurCtrlFeq          LONG
FieldColorQueue     QUEUE
Feq                   LONG
OldColor              LONG
                    END

  CODE
  GlobalResponse = ThisWindow.Run()                        ! Opens the window and starts an Accept Loop

!---------------------------------------------------------------------------
DefineListboxStyle ROUTINE
!|
!| This routine create all the styles to be shared in this window
!| It`s called after the window open
!|
!---------------------------------------------------------------------------

ThisWindow.Ask PROCEDURE

  CODE
  CASE SELF.Request                                        ! Configure the action message text
  OF ViewRecord
    ActionMessage = 'View Record'
  OF InsertRecord
    GlobalErrors.Throw(Msg:InsertIllegal)
    RETURN
  OF ChangeRecord
    ActionMessage = 'Record Will Be Changed'
  OF DeleteRecord
    GlobalErrors.Throw(Msg:DeleteIllegal)
    RETURN
  END
  QuickWindow{PROP:Text} = ActionMessage                   ! Display status message in title bar
  PARENT.Ask


ThisWindow.Init PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  GlobalErrors.SetProcedureName('UpdateSettings')
  SELF.Request = GlobalRequest                             ! Store the incoming request
  ReturnValue = PARENT.Init()
  IF ReturnValue THEN RETURN ReturnValue.
  SELF.FirstField = ?Set:Nr:Prompt
  SELF.VCRRequest &= VCRRequest
  SELF.Errors &= GlobalErrors                              ! Set this windows ErrorManager to the global ErrorManager
  SELF.AddItem(Toolbar)
  CLEAR(GlobalRequest)                                     ! Clear GlobalRequest after storing locally
  CLEAR(GlobalResponse)
  SELF.HistoryKey = CtrlH
  SELF.AddHistoryFile(Set:Record,History::Set:Record)
  SELF.AddHistoryField(?Set:Nr,1)
  SELF.AddHistoryField(?Set:Name,2)
  SELF.AddHistoryField(?Set:Type,3)
  SELF.AddHistoryField(?Set:Content,4)
  SELF.AddUpdateFile(Access:Settings)
  SELF.AddItem(?Cancel,RequestCancelled)                   ! Add the cancel control to the window manager
  Relate:Settings.Open                                     ! File Settings used by this procedure, so make sure it's RelationManager is open
  SELF.FilesOpened = True
  SELF.Primary &= Relate:Settings
  IF SELF.Request = ViewRecord AND NOT SELF.BatchProcessing ! Setup actions for ViewOnly Mode
    SELF.InsertAction = Insert:None
    SELF.DeleteAction = Delete:None
    SELF.ChangeAction = Change:None
    SELF.CancelAction = Cancel:Cancel
    SELF.OkControl = 0
  ELSE
    SELF.InsertAction = Insert:None                        ! Inserts not allowed
    SELF.DeleteAction = Delete:None                        ! Deletes not allowed
    SELF.ChangeAction = Change:Caller                      ! Changes allowed
    SELF.CancelAction = Cancel:Cancel+Cancel:Query         ! Confirm cancel
    SELF.OkControl = ?OK
    IF SELF.PrimeUpdate() THEN RETURN Level:Notify.
  END
  SELF.Open(QuickWindow)                                   ! Open window
  !Setting the LineHeight for every control of type LIST/DROP or COMBO in the window using the global setting.
  Do DefineListboxStyle
  IF SELF.Request = ViewRecord                             ! Configure controls for View Only mode
    ?Set:Nr{PROP:ReadOnly} = True
    ?Set:Name{PROP:ReadOnly} = True
    ?Set:Content{PROP:ReadOnly} = True
  END
  Resizer.Init(AppStrategy:Surface,Resize:SetMinSize)      ! Controls like list boxes will resize, whilst controls like buttons will move
  SELF.AddItem(Resizer)                                    ! Add resizer to window manager
  INIMgr.Fetch('UpdateSettings',QuickWindow)               ! Restore window settings from non-volatile store
  Resizer.Resize                                           ! Reset required after window size altered by INI manager
  SELF.SetAlerts()
  RETURN ReturnValue


ThisWindow.Kill PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  ReturnValue = PARENT.Kill()
  IF ReturnValue THEN RETURN ReturnValue.
  IF SELF.FilesOpened
    Relate:Settings.Close
  END
  IF SELF.Opened
    INIMgr.Update('UpdateSettings',QuickWindow)            ! Save window data to non-volatile store
  END
  GlobalErrors.SetProcedureName
  RETURN ReturnValue


ThisWindow.Run PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  ReturnValue = PARENT.Run()
  IF SELF.Request = ViewRecord                             ! In View Only mode always signal RequestCancelled
    ReturnValue = RequestCancelled
  END
  RETURN ReturnValue


ThisWindow.TakeAccepted PROCEDURE

ReturnValue          BYTE,AUTO

Looped BYTE
  CODE
  LOOP                                                     ! This method receive all EVENT:Accepted's
    IF Looped
      RETURN Level:Notify
    ELSE
      Looped = 1
    END
  ReturnValue = PARENT.TakeAccepted()
    CASE ACCEPTED()
    OF ?OK
      ThisWindow.Update()
      IF SELF.Request = ViewRecord AND NOT SELF.BatchProcessing THEN
         POST(EVENT:CloseWindow)
      END
    END
    RETURN ReturnValue
  END
  ReturnValue = Level:Fatal
  RETURN ReturnValue


ThisWindow.TakeWindowEvent PROCEDURE

ReturnValue          BYTE,AUTO

Looped BYTE
  CODE
  LOOP                                                     ! This method receives all window specific events
    IF Looped
      RETURN Level:Notify
    ELSE
      Looped = 1
    END
    CASE EVENT()
    OF EVENT:CloseDown
      IF GLO:CleanCloseDown
         SELF.CancelAction = Cancel:Cancel
      END
    END
  ReturnValue = PARENT.TakeWindowEvent()
    RETURN ReturnValue
  END
  ReturnValue = Level:Fatal
  RETURN ReturnValue


Resizer.Init PROCEDURE(BYTE AppStrategy=AppStrategy:Resize,BYTE SetWindowMinSize=False,BYTE SetWindowMaxSize=False)


  CODE
  PARENT.Init(AppStrategy,SetWindowMinSize,SetWindowMaxSize)
  SELF.SetParentDefaults()                                 ! Calculate default control parent-child relationships based upon their positions on the window

!!! <summary>
!!! Generated from procedure template - Window
!!! Projects
!!! </summary>
UpdateProjects PROCEDURE 

CurrentTab           STRING(80)                            !
startwizard_flag     BYTE                                  !
pastepath            CSTRING(1024)                         !
sicpath              CSTRING(255)                          !
ActionMessage        CSTRING(40)                           !
BRW7::View:Browse    VIEW(Paths)
                       PROJECT(Pat:Nr)
                       PROJECT(Pat:LookupPath)
                       PROJECT(Pat:Subdirs)
                     END
Queue:Browse         QUEUE                            !Queue declaration for browse/combo box using ?List
Pat:Nr                 LIKE(Pat:Nr)                   !List box control field - type derived from field
Pat:LookupPath         LIKE(Pat:LookupPath)           !List box control field - type derived from field
Pat:Subdirs            LIKE(Pat:Subdirs)              !List box control field - type derived from field
Mark                   BYTE                           !Entry's marked status
ViewPosition           STRING(1024)                   !Entry's view position
                     END
History::Pro:Record  LIKE(Pro:RECORD),THREAD
BRW7::FormatManager  ListFormatManagerClass,THREAD ! LFM object
BRW7::PopupTextExt   STRING(1024)                 ! Extended popup text
BRW7::PopupChoice    SIGNED                       ! Popup current choice
BRW7::PopupChoiceOn  BYTE(1)                      ! Popup on/off choice
BRW7::PopupChoiceExec BYTE(0)                     ! Popup executed
QuickWindow          WINDOW('Projects'),AT(,,445,261),FONT('Microsoft Sans Serif',8,,FONT:regular,CHARSET:DEFAULT), |
  RESIZE,MAXIMIZE,CENTERED,CENTER,GRAY,IMM,MDI,HLP('UpdateProjects'),SYSTEM,TIMER(100),WALLPAPER('media\Hint' & |
  'ergrund2018_verlauf_2000.png')
                       BUTTON('&OK'),AT(339,244,50,15),USE(?OK),LEFT,ICON('WAOK.ICO'),DEFAULT,FLAT,TIP('Änderungen' & |
  ' übernehmen')
                       BUTTON('&Close'),AT(393,244,50,15),USE(?Cancel),LEFT,ICON('WACANCEL.ICO'),FLAT,MSG('Fenster sc' & |
  'hliessen ohne Speichern'),TIP('Fenster schliessen ohne Speichern')
                       BUTTON('&Help'),AT(387,17,50,15),USE(?Help),LEFT,ICON('WAHELP.ICO'),FLAT,HIDE,MSG('See Help Window'), |
  STD(STD:Help),TIP('See Help Window')
                       LIST,AT(12,102,424,132),USE(?List),RIGHT(1),DROPID('~TEXT','~FILE','~BMP'),FORMAT('30L(2)|M~N' & |
  'r~L(1)@n_5@1016L(2)|M~Lookup Path~L(0)@s254@12L(2)|M~Subdirs~L(0)@n3@'),FROM(Queue:Browse), |
  IMM,TIP('Drop Path from clipboard, to add')
                       ENTRY(@n_4),AT(421,2,21,10),USE(Pro:Nr),RIGHT(1),HIDE,READONLY
                       PROMPT('Nr:'),AT(407,3),USE(?Pro:Nr:Prompt),FONT(,,COLOR:ACTIVECAPTION),HIDE,TRN
                       ENTRY(@s60),AT(59,10,289,10),USE(Pro:Name),FONT(,,,FONT:bold),MSG('Name of Field'),TIP('Name of Field')
                       PROMPT('Name:'),AT(6,10),USE(?Pro:Name:Prompt),FONT(,,COLOR:ACTIVECAPTION),TRN
                       PROMPT('Description:'),AT(6,25),USE(?Pro:Description:Prompt),FONT(,,COLOR:ACTIVECAPTION),TRN
                       ENTRY(@s254),AT(59,25,289,10),USE(Pro:Description),DROPID('~File','~Text','~'),MSG('of Project'), |
  TIP('of Project')
                       ENTRY(@s254),AT(12,86,397),USE(pastepath),COLOR(00AAE8EEh),DROPID('~TEXT','~FILE','~BMP'), |
  TIP('drop here to add path')
                       STRING('Drop in list or paste clipboard to yellow entry-field to add path:'),AT(11,74),USE(?STRING1), |
  FONT(,7,,FONT:regular+FONT:italic)
                       BUTTON('delete path record'),AT(11,239,,20),USE(?BUTTONDelete),LEFT,ICON(ICON:Cross),TIP('delete the' & |
  ' highlighted entry in list')
                       BUTTON,AT(414,86,23,14),USE(?BUTTONplus),ICON(ICON:Open),TIP('add path from entry-field' & |
  ' to the left')
                       PROMPT('Startfile:'),AT(6,44),USE(?Pro:Startfile:Prompt),FONT(,,COLOR:ACTIVECAPTION),TRN
                       ENTRY(@s255),AT(59,45,289,10),USE(Pro:Startfile),LEFT,DROPID('~FILE'),MSG('with path'),TIP('with path')
                       PROMPT('Types:'),AT(261,59),USE(?Pro:Types:Prompt),FONT(,,COLOR:ACTIVECAPTION),TRN
                       ENTRY(@s20),AT(288,60,60,10),USE(Pro:Types),MSG('allowed Extensions Filetype'),TIP('allowed Ex' & |
  'tensions Filetype')
                       BUTTON('Test'),AT(181,60,50),USE(?BUTTON1),HIDE
                       BUTTON('Wizard'),AT(353,10,83,72),USE(?BUTTONWizard)
                       BUTTON('files of project'),AT(109,239,,20),USE(?BUTTONFiles),TIP('scan all paths for pr' & |
  'oject files')
                     END

BRW7::LastSortOrder       BYTE
BRW7::SortHeader  CLASS(SortHeaderClassType) !Declare SortHeader Class
QueueResorted          PROCEDURE(STRING pString),VIRTUAL
                  END
BRW7::AutoSizeColumn CLASS(AutoSizeColumnClassType)
               END
ThisWindow           CLASS(WindowManager)
Ask                    PROCEDURE(),DERIVED
Init                   PROCEDURE(),BYTE,PROC,DERIVED
Kill                   PROCEDURE(),BYTE,PROC,DERIVED
PrimeFields            PROCEDURE(),PROC,DERIVED
Reset                  PROCEDURE(BYTE Force=0),DERIVED
Run                    PROCEDURE(),BYTE,PROC,DERIVED
SetAlerts              PROCEDURE(),DERIVED
TakeAccepted           PROCEDURE(),BYTE,PROC,DERIVED
TakeEvent              PROCEDURE(),BYTE,PROC,DERIVED
TakeFieldEvent         PROCEDURE(),BYTE,PROC,DERIVED
TakeWindowEvent        PROCEDURE(),BYTE,PROC,DERIVED
                     END

Toolbar              ToolbarClass
Resizer              CLASS(WindowResizeClass)
Init                   PROCEDURE(BYTE AppStrategy=AppStrategy:Resize,BYTE SetWindowMinSize=False,BYTE SetWindowMaxSize=False)
                     END

BRW7                 CLASS(BrowseClass)                    ! Browse using ?List
Q                      &Queue:Browse                  !Reference to browse queue
SetSort                PROCEDURE(BYTE NewOrder,BYTE Force),BYTE,PROC,DERIVED
TakeNewSelection       PROCEDURE(),DERIVED
                     END

CurCtrlFeq          LONG
FieldColorQueue     QUEUE
Feq                   LONG
OldColor              LONG
                    END

  CODE
  GlobalResponse = ThisWindow.Run()               ! Opens the window and starts an Accept Loop

!---------------------------------------------------------------------------
DefineListboxStyle ROUTINE
!|
!| This routine create all the styles to be shared in this window
!| It`s called after the window open
!|
!---------------------------------------------------------------------------
scan_action_1       ROUTINE
    
    disable(?BUTTON1)
    DISABLE(?BUTTONWizard)
    DISABLE(?BUTTONFiles)

    Free(MemQueue)
    glo:messagestring = ''
    glo:depth = 0

!message(testmessage)

    result# = scan_in_file(Pro:Startfile)

  !  glo:messagestring = glo:messagestring & '<13,10>' & par:file

    LOOP i# = 1 to records(MemQueue)
        get(MemQueue,i#)
    
        execute MQ:depth
            imp:str" = '-'
            imp:str" = '--'
            imp:str" = '---'
            imp:str" = '----'
            imp:str" = '-----'
            imp:str" = '------'
            imp:str" = '-------'
            imp:str" = '--------'
        ELSE
            imp:str" = '...'
        END
    
        glo:messagestring = glo:messagestring & MQ:depth & ': ' & clip(imp:str") & clip(MQ:Line) & '<13,10>'
    END

    post(EVENT:Notify,,glo:messagethread,1)

    ENABLE(?BUTTON1)
    enable(?BUTTONWizard)
    enable(?BUTTONFiles)




dropaction          routine
        
    if instring(',',pastepath,1,1)
        message('only 1 path per time','no multi-selection')
        EXIT
    END

    if instring('.',pastepath,1,1)
        message('stripping the filename off the path','only the path')
        pos# = instring('\',pastepath,-1,len(clip(pastepath)))  !get the last backslash
        Pat:LookupPath = SUB(pastepath,1,pos#)
        
    ELSE
        Pat:LookupPath = pastepath
    END
       
    sicpath = Pat:LookupPath
    
    Pat:ProNr = Pro:Nr
    get(Paths,Pat:NameKey)
    if errorcode()
        set(Pat:NrKey)
        previous(Paths)
        Pat:Nr +=1
        Pat:ProNr = Pro:Nr
        Pat:LookupPath = sicpath
        Pat:Subdirs = TRUE
        add(Paths)
        
        BRW7.ResetFromFile
    ELSE
        beep(BEEP:SystemExclamation)
    END

ThisWindow.Ask PROCEDURE

  CODE
  CASE SELF.Request                               ! Configure the action message text
  OF ViewRecord
    ActionMessage = 'View Record'
  OF InsertRecord
    ActionMessage = 'Record Will Be Added'
  OF ChangeRecord
    ActionMessage = 'Record Will Be Changed'
  END
  QuickWindow{PROP:Text} = ActionMessage          ! Display status message in title bar
  PARENT.Ask


ThisWindow.Init PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  GlobalErrors.SetProcedureName('UpdateProjects')
  SELF.Request = GlobalRequest                    ! Store the incoming request
  ReturnValue = PARENT.Init()
  IF ReturnValue THEN RETURN ReturnValue.
  SELF.FirstField = ?OK
  SELF.VCRRequest &= VCRRequest
  SELF.Errors &= GlobalErrors                     ! Set this windows ErrorManager to the global ErrorManager
  SELF.AddItem(Toolbar)
  CLEAR(GlobalRequest)                            ! Clear GlobalRequest after storing locally
  CLEAR(GlobalResponse)
  SELF.HistoryKey = CtrlH
  SELF.AddHistoryFile(Pro:Record,History::Pro:Record)
  SELF.AddHistoryField(?Pro:Nr,1)
  SELF.AddHistoryField(?Pro:Name,2)
  SELF.AddHistoryField(?Pro:Description,3)
  SELF.AddHistoryField(?Pro:Startfile,4)
  SELF.AddHistoryField(?Pro:Types,5)
  SELF.AddUpdateFile(Access:Projects)
  SELF.AddItem(?Cancel,RequestCancelled)          ! Add the cancel control to the window manager
  Relate:Files.SetOpenRelated()
  Relate:Files.Open                               ! File Files used by this procedure, so make sure it's RelationManager is open
  Relate:Includes.Open                            ! File Includes used by this procedure, so make sure it's RelationManager is open
  SELF.FilesOpened = True
  SELF.Primary &= Relate:Projects
  IF SELF.Request = ViewRecord AND NOT SELF.BatchProcessing ! Setup actions for ViewOnly Mode
    SELF.InsertAction = Insert:None
    SELF.DeleteAction = Delete:None
    SELF.ChangeAction = Change:None
    SELF.CancelAction = Cancel:Cancel
    SELF.OkControl = 0
  ELSE
    SELF.ChangeAction = Change:Caller             ! Changes allowed
    SELF.CancelAction = Cancel:Cancel+Cancel:Query ! Confirm cancel
    SELF.OkControl = ?OK
    IF SELF.PrimeUpdate() THEN RETURN Level:Notify.
  END
  BRW7.Init(?List,Queue:Browse.ViewPosition,BRW7::View:Browse,Queue:Browse,Relate:Paths,SELF) ! Initialize the browse manager
        BRW7.DeleteControl=?BUTTONDelete          !set the control to delete records
  
  
  SELF.Open(QuickWindow)                          ! Open window
  !Setting the LineHeight for every control of type LIST/DROP or COMBO in the window using the global setting.
  ?List{PROP:LineHeight} = 12
  Do DefineListboxStyle
  IF SELF.Request = ViewRecord                    ! Configure controls for View Only mode
    ?Pro:Nr{PROP:ReadOnly} = True
    ?Pro:Name{PROP:ReadOnly} = True
    ?Pro:Description{PROP:ReadOnly} = True
    ?pastepath{PROP:ReadOnly} = True
    DISABLE(?BUTTONDelete)
    DISABLE(?BUTTONplus)
    ?Pro:Startfile{PROP:ReadOnly} = True
    ?Pro:Types{PROP:ReadOnly} = True
    DISABLE(?BUTTON1)
    DISABLE(?BUTTONWizard)
    DISABLE(?BUTTONFiles)
  END
  Resizer.Init(AppStrategy:Surface,Resize:SetMinSize) ! Controls like list boxes will resize, whilst controls like buttons will move
  SELF.AddItem(Resizer)                           ! Add resizer to window manager
  BRW7.Q &= Queue:Browse
  BRW7.AddSortOrder(,)                            ! Add the sort order for  for sort order 1
  BRW7.SetFilter('(Pro:Nr = Pat:ProNr)')          ! Apply filter expression to browse
  BRW7.AddField(Pat:Nr,BRW7.Q.Pat:Nr)             ! Field Pat:Nr is a hot field or requires assignment from browse
  BRW7.AddField(Pat:LookupPath,BRW7.Q.Pat:LookupPath) ! Field Pat:LookupPath is a hot field or requires assignment from browse
  BRW7.AddField(Pat:Subdirs,BRW7.Q.Pat:Subdirs)   ! Field Pat:Subdirs is a hot field or requires assignment from browse
  INIMgr.Fetch('UpdateProjects',QuickWindow)      ! Restore window settings from non-volatile store
  Resizer.Resize                                  ! Reset required after window size altered by INI manager
  BRW7.AddToolbarTarget(Toolbar)                  ! Browse accepts toolbar control
  BRW7.ToolbarItem.HelpButton = ?Help
  BRW7::FormatManager.SaveFormat = True
  ! List Format Manager initialization
  BRW7::FormatManager.Init('ObjectHelper','UpdateProjects',1,?List,7,BRW7::PopupTextExt,Queue:Browse,3,LFM_CFile,LFM_CFile.Record)
  BRW7::FormatManager.BindInterface(,,,'.\ObjectHelper.INI')
  SELF.SetAlerts()
  BRW7::AutoSizeColumn.Init()
  BRW7::AutoSizeColumn.AddListBox(?List,Queue:Browse)
  !Initialize the Sort Header using the Browse Queue and Browse Control
  BRW7::SortHeader.Init(Queue:Browse,?List,'','',BRW7::View:Browse)
  BRW7::SortHeader.UseSortColors = False
  RETURN ReturnValue


ThisWindow.Kill PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  ReturnValue = PARENT.Kill()
  IF ReturnValue THEN RETURN ReturnValue.
  IF SELF.FilesOpened
    Relate:Files.Close
    Relate:Includes.Close
  !Kill the Sort Header
  BRW7::SortHeader.Kill()
  END
  ! List Format Manager destructor
  BRW7::FormatManager.Kill() 
  BRW7::AutoSizeColumn.Kill()
  IF SELF.Opened
    INIMgr.Update('UpdateProjects',QuickWindow)            ! Save window data to non-volatile store
  END
  GlobalErrors.SetProcedureName
  RETURN ReturnValue


ThisWindow.PrimeFields PROCEDURE

  CODE
  Pro:Types = '.ino,.h'
  PARENT.PrimeFields


ThisWindow.Reset PROCEDURE(BYTE Force=0)

  CODE
  SELF.ForcedReset += Force
  IF QuickWindow{Prop:AcceptAll} THEN RETURN.
  Pat:ProNr = Pro:Nr                                       ! Assign linking field value
  Access:Paths.Fetch(Pat:ProNrKey)
  PARENT.Reset(Force)


ThisWindow.Run PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  ReturnValue = PARENT.Run()
  IF SELF.Request = ViewRecord                             ! In View Only mode always signal RequestCancelled
    ReturnValue = RequestCancelled
  END
  RETURN ReturnValue


ThisWindow.SetAlerts PROCEDURE

  CODE
  PARENT.SetAlerts
  !Initialize the Sort Header using the Browse Queue and Browse Control
  BRW7::SortHeader.SetAlerts()


ThisWindow.TakeAccepted PROCEDURE

ReturnValue          BYTE,AUTO

Looped BYTE
  CODE
  LOOP                                                     ! This method receive all EVENT:Accepted's
    IF Looped
      RETURN Level:Notify
    ELSE
      Looped = 1
    END
  ReturnValue = PARENT.TakeAccepted()
    CASE ACCEPTED()
    OF ?OK
      ThisWindow.Update()
      IF SELF.Request = ViewRecord AND NOT SELF.BatchProcessing THEN
         POST(EVENT:CloseWindow)
      END
    OF ?BUTTONDelete
      ThisWindow.Update()
      ! ist in deletecontrol gesetzt
    OF ?BUTTONplus
      ThisWindow.Update()
      do dropaction
    OF ?BUTTON1
      ThisWindow.Update()
      if glo:messagethread < 1 then glo:messagethread = start(messages).
      
        do scan_action_1
    OF ?BUTTONWizard
      ThisWindow.Update()
      if glo:messagethread < 1 
          glo:messagewindowopen = FALSE
          glo:messagethread = start(messages)
      .
      
      if RECORDS(MemQueue) < 1
          do scan_action_1
      END
      
      startwizard_flag = TRUE
      
      !QuickWindow{PROP:Iconize} = TRUE
      
      
      
      ThisWindow.Update
      
      
      
      
    OF ?BUTTONFiles
      ThisWindow.Update()
      START(BrowseFiles, 25000)
      ThisWindow.Reset
    END
    RETURN ReturnValue
  END
  ReturnValue = Level:Fatal
  RETURN ReturnValue


ThisWindow.TakeEvent PROCEDURE

ReturnValue          BYTE,AUTO

Looped BYTE
  CODE
  LOOP                                                     ! This method receives all events
    IF Looped
      RETURN Level:Notify
    ELSE
      Looped = 1
    END
  !Take Sort Headers Events
  IF BRW7::SortHeader.TakeEvents()
     RETURN Level:Notify
  END
  IF BRW7::AutoSizeColumn.TakeEvents()
     RETURN Level:Notify
  END
  ReturnValue = PARENT.TakeEvent()
    RETURN ReturnValue
  END
  ReturnValue = Level:Fatal
  RETURN ReturnValue


ThisWindow.TakeFieldEvent PROCEDURE

ReturnValue          BYTE,AUTO

Looped BYTE
  CODE
  LOOP                                                     ! This method receives all field specific events
    IF Looped
      RETURN Level:Notify
    ELSE
      Looped = 1
    END
  ReturnValue = PARENT.TakeFieldEvent()
  CASE FIELD()
  OF ?List
    CASE EVENT()
    OF EVENT:Drop
      pastepath = dropid()
      do dropaction
    END
  OF ?pastepath
    CASE EVENT()
    OF EVENT:Drop
      pastepath = dropid()
      do dropaction
    END
  OF ?Pro:Startfile
    CASE EVENT()
    OF EVENT:Drop
      pastepath = dropid()
      if exists(pastepath)
          Pro:Startfile = pastepath
          DISPLAY
      ELSE
          message('No such file')
      END
    END
  END
    RETURN ReturnValue
  END
  ReturnValue = Level:Fatal
  RETURN ReturnValue


ThisWindow.TakeWindowEvent PROCEDURE

ReturnValue          BYTE,AUTO

Looped BYTE
  CODE
  LOOP                                                     ! This method receives all window specific events
    IF Looped
      RETURN Level:Notify
    ELSE
      Looped = 1
    END
    CASE EVENT()
    OF EVENT:CloseDown
      IF GLO:CleanCloseDown
         SELF.CancelAction = Cancel:Cancel
      END
    END
  ReturnValue = PARENT.TakeWindowEvent()
    CASE EVENT()
    OF EVENT:Timer
      if startwizard_flag = TRUE
          ?BUTTONWizard{PROP:Background} = Color:Blue
          BEEP
          if glo:messagewindowopen = TRUE
              startwizard_flag = FALSE
              !QuickWindow{PROP:Iconize} = TRUE
              wizard()
              !QuickWindow{PROP:Iconize} = FALSE
          END
      ELSE
              ?BUTTONWizard{PROP:Background} = COLOR:Green
      END
      !GlobalErrors.
    END
    RETURN ReturnValue
  END
  ReturnValue = Level:Fatal
  RETURN ReturnValue


Resizer.Init PROCEDURE(BYTE AppStrategy=AppStrategy:Resize,BYTE SetWindowMinSize=False,BYTE SetWindowMaxSize=False)


  CODE
  PARENT.Init(AppStrategy,SetWindowMinSize,SetWindowMaxSize)
  SELF.SetParentDefaults()                                 ! Calculate default control parent-child relationships based upon their positions on the window


BRW7.SetSort PROCEDURE(BYTE NewOrder,BYTE Force)

ReturnValue          BYTE,AUTO

  CODE
  ReturnValue = PARENT.SetSort(NewOrder,Force)
  IF BRW7::LastSortOrder<>NewOrder THEN
     BRW7::SortHeader.ClearSort()
  END
  IF BRW7::LastSortOrder <> NewOrder THEN
     BRW7::FormatManager.SetCurrentFormat(CHOOSE(NewOrder>0,2,NewOrder+2),'SortOrder'&CHOOSE(NewOrder>0,1,NewOrder+1))
  END
  BRW7::LastSortOrder=NewOrder
  RETURN ReturnValue


BRW7.TakeNewSelection PROCEDURE

  CODE
  IF BRW7::PopupChoiceOn THEN
     IF KEYCODE() = MouseRightUp
        BRW7::PopupTextExt = ''
        BRW7::PopupChoiceExec = True
        BRW7::FormatManager.MakePopup(BRW7::PopupTextExt)
        IF SELF.Popup.GetItems() THEN
           BRW7::PopupTextExt = '|-|' & CLIP(BRW7::PopupTextExt)
        END
        BRW7::FormatManager.SetPopupChoice(SELF.Popup.GetItems(True)+1,0)
        SELF.Popup.AddMenu(CLIP(BRW7::PopupTextExt),SELF.Popup.GetItems()+1)
        BRW7::FormatManager.SetPopupChoice(,SELF.Popup.GetItems(True))
     ELSE
        BRW7::PopupChoiceExec = False
     END
  END
  PARENT.TakeNewSelection
  IF BRW7::PopupChoiceOn AND BRW7::PopupChoiceExec THEN
     BRW7::PopupChoiceExec = False
     BRW7::PopupChoice = SELF.Popup.GetLastNumberSelection()
     SELF.Popup.DeleteMenu(BRW7::PopupTextExt)
     BRW7::SortHeader.RestoreHeaderText()
     BRW7.RestoreSort()
     IF BRW7::FormatManager.DispatchChoice(BRW7::PopupChoice)
        BRW7::SortHeader.ResetSort()
     ELSE
        BRW7::SortHeader.SortQueue()
     END
  END

BRW7::SortHeader.QueueResorted       PROCEDURE(STRING pString)
  CODE
    IF pString = ''
       BRW7.RestoreSort()
       BRW7.ResetSort(True)
    ELSE
       BRW7.ReplaceSort(pString)
    END
!!! <summary>
!!! Generated from procedure template - Window
!!! Select a Projects Record
!!! </summary>
SelectProjects PROCEDURE 

CurrentTab           STRING(80)                            !
BRW1::View:Browse    VIEW(Projects)
                       PROJECT(Pro:Nr)
                       PROJECT(Pro:Name)
                       PROJECT(Pro:Description)
                     END
Queue:Browse:1       QUEUE                            !Queue declaration for browse/combo box using ?Browse:1
Pro:Nr                 LIKE(Pro:Nr)                   !List box control field - type derived from field
Pro:Name               LIKE(Pro:Name)                 !List box control field - type derived from field
Pro:Description        LIKE(Pro:Description)          !List box control field - type derived from field
Mark                   BYTE                           !Entry's marked status
ViewPosition           STRING(1024)                   !Entry's view position
                     END
BRW1::FormatManager  ListFormatManagerClass,THREAD ! LFM object
BRW1::PopupTextExt   STRING(1024)                 ! Extended popup text
BRW1::PopupChoice    SIGNED                       ! Popup current choice
BRW1::PopupChoiceOn  BYTE(1)                      ! Popup on/off choice
BRW1::PopupChoiceExec BYTE(0)                     ! Popup executed
QuickWindow          WINDOW('Select a Projects Record'),AT(,,232,198),FONT('Microsoft Sans Serif',8,,FONT:regular, |
  CHARSET:DEFAULT),RESIZE,CENTER,GRAY,IMM,MDI,HLP('SelectProjects'),SYSTEM
                       LIST,AT(8,30,216,124),USE(?Browse:1),HVSCROLL,FORMAT('64R(2)|M~Nr~C(0)@n-14@80L(2)|M~Na' & |
  'me~L(2)@s60@80L(2)|M~Description~L(2)@s254@'),FROM(Queue:Browse:1),IMM,MSG('Projects')
                       BUTTON('&Select'),AT(174,158,50,14),USE(?Select:2),LEFT,ICON('WASELECT.ICO'),FLAT,MSG('Select the Record'), |
  TIP('Select the Record')
                       SHEET,AT(4,4,224,172),USE(?CurrentTab)
                         TAB('&1) NrKey'),USE(?Tab:2)
                         END
                         TAB('&2) NameKey'),USE(?Tab:3)
                         END
                       END
                       BUTTON('&Schliessen'),AT(178,180,50,14),USE(?Close),LEFT,ICON('WACLOSE.ICO'),FLAT,MSG('Fenster schliesen'), |
  TIP('Fenster schliessen')
                     END

BRW1::LastSortOrder       BYTE
BRW1::AutoSizeColumn CLASS(AutoSizeColumnClassType)
               END
ThisWindow           CLASS(WindowManager)
Init                   PROCEDURE(),BYTE,PROC,DERIVED
Kill                   PROCEDURE(),BYTE,PROC,DERIVED
TakeEvent              PROCEDURE(),BYTE,PROC,DERIVED
TakeWindowEvent        PROCEDURE(),BYTE,PROC,DERIVED
                     END

Toolbar              ToolbarClass
BRW1                 CLASS(BrowseClass)                    ! Browse using ?Browse:1
Q                      &Queue:Browse:1                !Reference to browse queue
Init                   PROCEDURE(SIGNED ListBox,*STRING Posit,VIEW V,QUEUE Q,RelationManager RM,WindowManager WM)
ResetSort              PROCEDURE(BYTE Force),BYTE,PROC,DERIVED
SetSort                PROCEDURE(BYTE NewOrder,BYTE Force),BYTE,PROC,DERIVED
TakeNewSelection       PROCEDURE(),DERIVED
                     END

BRW1::Sort0:Locator  StepLocatorClass                      ! Default Locator
BRW1::Sort1:Locator  StepLocatorClass                      ! Conditional Locator - CHOICE(?CurrentTab) = 2
BRW1::Sort0:StepClass StepLongClass                        ! Default Step Manager
BRW1::Sort1:StepClass StepStringClass                      ! Conditional Step Manager - CHOICE(?CurrentTab) = 2
Resizer              CLASS(WindowResizeClass)
Init                   PROCEDURE(BYTE AppStrategy=AppStrategy:Resize,BYTE SetWindowMinSize=False,BYTE SetWindowMaxSize=False)
                     END


  CODE
  GlobalResponse = ThisWindow.Run()               ! Opens the window and starts an Accept Loop

!---------------------------------------------------------------------------
DefineListboxStyle ROUTINE
!|
!| This routine create all the styles to be shared in this window
!| It`s called after the window open
!|
!---------------------------------------------------------------------------

ThisWindow.Init PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  GlobalErrors.SetProcedureName('SelectProjects')
  SELF.Request = GlobalRequest                    ! Store the incoming request
  ReturnValue = PARENT.Init()
  IF ReturnValue THEN RETURN ReturnValue.
  SELF.FirstField = ?Browse:1
  SELF.VCRRequest &= VCRRequest
  SELF.Errors &= GlobalErrors                     ! Set this windows ErrorManager to the global ErrorManager
  SELF.AddItem(Toolbar)
  CLEAR(GlobalRequest)                            ! Clear GlobalRequest after storing locally
  CLEAR(GlobalResponse)
  IF SELF.Request = SelectRecord
     SELF.AddItem(?Close,RequestCancelled)        ! Add the close control to the window manger
  ELSE
     SELF.AddItem(?Close,RequestCompleted)        ! Add the close control to the window manger
  END
  Relate:Projects.SetOpenRelated()
  Relate:Projects.Open                            ! File Projects used by this procedure, so make sure it's RelationManager is open
  SELF.FilesOpened = True
  BRW1.Init(?Browse:1,Queue:Browse:1.ViewPosition,BRW1::View:Browse,Queue:Browse:1,Relate:Projects,SELF) ! Initialize the browse manager
  SELF.Open(QuickWindow)                          ! Open window
  !Setting the LineHeight for every control of type LIST/DROP or COMBO in the window using the global setting.
  ?Browse:1{PROP:LineHeight} = 12
  Do DefineListboxStyle
  BRW1.Q &= Queue:Browse:1
  BRW1::Sort1:StepClass.Init(+ScrollSort:AllowAlpha,ScrollBy:Runtime) ! Moveable thumb based upon Pro:Name for sort order 1
  BRW1.AddSortOrder(BRW1::Sort1:StepClass,Pro:NameKey) ! Add the sort order for Pro:NameKey for sort order 1
  BRW1.AddLocator(BRW1::Sort1:Locator)            ! Browse has a locator for sort order 1
  BRW1::Sort1:Locator.Init(,Pro:Name,1,BRW1)      ! Initialize the browse locator using  using key: Pro:NameKey , Pro:Name
  BRW1::Sort0:StepClass.Init(+ScrollSort:AllowAlpha) ! Moveable thumb based upon Pro:Nr for sort order 2
  BRW1.AddSortOrder(BRW1::Sort0:StepClass,Pro:NrKey) ! Add the sort order for Pro:NrKey for sort order 2
  BRW1.AddLocator(BRW1::Sort0:Locator)            ! Browse has a locator for sort order 2
  BRW1::Sort0:Locator.Init(,Pro:Nr,1,BRW1)        ! Initialize the browse locator using  using key: Pro:NrKey , Pro:Nr
  BRW1.AddField(Pro:Nr,BRW1.Q.Pro:Nr)             ! Field Pro:Nr is a hot field or requires assignment from browse
  BRW1.AddField(Pro:Name,BRW1.Q.Pro:Name)         ! Field Pro:Name is a hot field or requires assignment from browse
  BRW1.AddField(Pro:Description,BRW1.Q.Pro:Description) ! Field Pro:Description is a hot field or requires assignment from browse
  Resizer.Init(AppStrategy:Surface,Resize:SetMinSize) ! Controls like list boxes will resize, whilst controls like buttons will move
  SELF.AddItem(Resizer)                           ! Add resizer to window manager
  INIMgr.Fetch('SelectProjects',QuickWindow)      ! Restore window settings from non-volatile store
  Resizer.Resize                                  ! Reset required after window size altered by INI manager
  BRW1::FormatManager.SaveFormat = True
  ! List Format Manager initialization
  BRW1::FormatManager.Init('ObjectHelper','SelectProjects',1,?Browse:1,1,BRW1::PopupTextExt,Queue:Browse:1,3,LFM_CFile,LFM_CFile.Record)
  BRW1::FormatManager.BindInterface(,,,'.\ObjectHelper.INI')
  SELF.SetAlerts()
  BRW1::AutoSizeColumn.Init()
  BRW1::AutoSizeColumn.AddListBox(?Browse:1,Queue:Browse:1)
  RETURN ReturnValue


ThisWindow.Kill PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  ReturnValue = PARENT.Kill()
  IF ReturnValue THEN RETURN ReturnValue.
  IF SELF.FilesOpened
    Relate:Projects.Close
  END
  ! List Format Manager destructor
  BRW1::FormatManager.Kill() 
  BRW1::AutoSizeColumn.Kill()
  IF SELF.Opened
    INIMgr.Update('SelectProjects',QuickWindow)            ! Save window data to non-volatile store
  END
  GlobalErrors.SetProcedureName
  RETURN ReturnValue


ThisWindow.TakeEvent PROCEDURE

ReturnValue          BYTE,AUTO

Looped BYTE
  CODE
  LOOP                                                     ! This method receives all events
    IF Looped
      RETURN Level:Notify
    ELSE
      Looped = 1
    END
  IF BRW1::AutoSizeColumn.TakeEvents()
     RETURN Level:Notify
  END
  ReturnValue = PARENT.TakeEvent()
    RETURN ReturnValue
  END
  ReturnValue = Level:Fatal
  RETURN ReturnValue


ThisWindow.TakeWindowEvent PROCEDURE

ReturnValue          BYTE,AUTO

Looped BYTE
  CODE
  LOOP                                                     ! This method receives all window specific events
    IF Looped
      RETURN Level:Notify
    ELSE
      Looped = 1
    END
    CASE EVENT()
    OF EVENT:CloseDown
      IF GLO:CleanCloseDown
         SELF.CancelAction = Cancel:Cancel
      END
    END
  ReturnValue = PARENT.TakeWindowEvent()
    RETURN ReturnValue
  END
  ReturnValue = Level:Fatal
  RETURN ReturnValue


BRW1.Init PROCEDURE(SIGNED ListBox,*STRING Posit,VIEW V,QUEUE Q,RelationManager RM,WindowManager WM)

  CODE
  SELF.SelectControl = ?Select:2
  SELF.HideSelect = 1                                      ! Hide the select button when disabled
  PARENT.Init(ListBox,Posit,V,Q,RM,WM)


BRW1.ResetSort PROCEDURE(BYTE Force)

ReturnValue          BYTE,AUTO

  CODE
  IF CHOICE(?CurrentTab) = 2
    RETURN SELF.SetSort(1,Force)
  ELSE
    RETURN SELF.SetSort(2,Force)
  END
  ReturnValue = PARENT.ResetSort(Force)
  RETURN ReturnValue


BRW1.SetSort PROCEDURE(BYTE NewOrder,BYTE Force)

ReturnValue          BYTE,AUTO

  CODE
  ReturnValue = PARENT.SetSort(NewOrder,Force)
  IF BRW1::LastSortOrder <> NewOrder THEN
     BRW1::FormatManager.SetCurrentFormat(CHOOSE(NewOrder>1,2,NewOrder+2),'SortOrder'&CHOOSE(NewOrder>1,1,NewOrder+1))
  END
  BRW1::LastSortOrder=NewOrder
  RETURN ReturnValue


BRW1.TakeNewSelection PROCEDURE

  CODE
  IF BRW1::PopupChoiceOn THEN
     IF KEYCODE() = MouseRightUp
        BRW1::PopupTextExt = ''
        BRW1::PopupChoiceExec = True
        BRW1::FormatManager.MakePopup(BRW1::PopupTextExt)
        IF SELF.Popup.GetItems() THEN
           BRW1::PopupTextExt = '|-|' & CLIP(BRW1::PopupTextExt)
        END
        BRW1::FormatManager.SetPopupChoice(SELF.Popup.GetItems(True)+1,0)
        SELF.Popup.AddMenu(CLIP(BRW1::PopupTextExt),SELF.Popup.GetItems()+1)
        BRW1::FormatManager.SetPopupChoice(,SELF.Popup.GetItems(True))
     ELSE
        BRW1::PopupChoiceExec = False
     END
  END
  PARENT.TakeNewSelection
  IF BRW1::PopupChoiceOn AND BRW1::PopupChoiceExec THEN
     BRW1::PopupChoiceExec = False
     BRW1::PopupChoice = SELF.Popup.GetLastNumberSelection()
     SELF.Popup.DeleteMenu(BRW1::PopupTextExt)
     IF BRW1::FormatManager.DispatchChoice(BRW1::PopupChoice)
     ELSE
     END
  END


Resizer.Init PROCEDURE(BYTE AppStrategy=AppStrategy:Resize,BYTE SetWindowMinSize=False,BYTE SetWindowMaxSize=False)


  CODE
  PARENT.Init(AppStrategy,SetWindowMinSize,SetWindowMaxSize)
  SELF.SetParentDefaults()                                 ! Calculate default control parent-child relationships based upon their positions on the window

!!! <summary>
!!! Generated from procedure template - Window
!!! Files
!!! </summary>
UpdateFiles PROCEDURE 

CurrentTab           STRING(80)                            !
ActionMessage        CSTRING(40)                           !
History::Files:Record LIKE(Files:RECORD),THREAD
QuickWindow          WINDOW('Files'),AT(,,560,152),FONT('Microsoft Sans Serif',8,,FONT:regular,CHARSET:DEFAULT), |
  RESIZE,CENTER,GRAY,IMM,MDI,HLP('UpdateFiles'),SYSTEM
                       SHEET,AT(4,4,553,128),USE(?CurrentTab)
                         TAB,USE(?Tab:1)
                           PROMPT('Path Name:'),AT(8,54),USE(?Files:PathName:Prompt),TRN
                           ENTRY(@s254),AT(61,54,483,10),USE(Files:Pathpt2),MSG('Name and Path  of File'),TIP('Name and P' & |
  'ath  of File')
                           PROMPT('Type:'),AT(8,100),USE(?Files:Type:Prompt),TRN
                           ENTRY(@s20),AT(61,100,84,10),USE(Files:Type),MSG('Extension Filetype'),TIP('Extension Filetype')
                           PROMPT('Filename:'),AT(8,74),USE(?Files:Filename:Prompt),TRN
                           ENTRY(@s60),AT(61,73),USE(Files:Filename),FONT(,12,,FONT:bold),LEFT,MSG('without path'),TIP('without path')
                           PROMPT('Lookup Path:'),AT(8,39),USE(?Pat:LookupPath:Prompt),TRN
                           ENTRY(@s254),AT(61,40,483,10),USE(Pat:LookupPath),MSG('Path to lookup in'),TIP('Path to lookup in')
                         END
                       END
                       BUTTON('&OK'),AT(442,135,50,15),USE(?OK),LEFT,ICON('WAOK.ICO'),DEFAULT,FLAT,TIP('Änderungen' & |
  ' übernehmen')
                       BUTTON('&Close'),AT(495,135,50,15),USE(?Cancel),LEFT,ICON('WACANCEL.ICO'),FLAT,MSG('Fenster sc' & |
  'hliessen ohne Speichern'),TIP('Fenster schliessen ohne Speichern')
                       BUTTON('&Help'),AT(8,135,50,15),USE(?Help),LEFT,ICON('WAHELP.ICO'),FLAT,HIDE,MSG('See Help Window'), |
  STD(STD:Help),TIP('See Help Window')
                       ENTRY(@n_6),AT(518,5,27,10),USE(Files:Nr),FONT(,7),RIGHT(1),READONLY,SKIP,TRN
                       PROMPT('Nr:'),AT(505,6),USE(?Files:Nr:Prompt),FONT(,7),TRN
                       ENTRY(@n_4),AT(94,5,27,10),USE(Files:ProNr),RIGHT(1)
                       PROMPT('Project-Nr:'),AT(41,6),USE(?Files:ProNr:Prompt),TRN
                     END

ThisWindow           CLASS(WindowManager)
Ask                    PROCEDURE(),DERIVED
Init                   PROCEDURE(),BYTE,PROC,DERIVED
Kill                   PROCEDURE(),BYTE,PROC,DERIVED
Reset                  PROCEDURE(BYTE Force=0),DERIVED
Run                    PROCEDURE(),BYTE,PROC,DERIVED
TakeAccepted           PROCEDURE(),BYTE,PROC,DERIVED
TakeWindowEvent        PROCEDURE(),BYTE,PROC,DERIVED
                     END

Toolbar              ToolbarClass
Resizer              CLASS(WindowResizeClass)
Init                   PROCEDURE(BYTE AppStrategy=AppStrategy:Resize,BYTE SetWindowMinSize=False,BYTE SetWindowMaxSize=False)
                     END

CurCtrlFeq          LONG
FieldColorQueue     QUEUE
Feq                   LONG
OldColor              LONG
                    END

  CODE
  GlobalResponse = ThisWindow.Run()                        ! Opens the window and starts an Accept Loop

!---------------------------------------------------------------------------
DefineListboxStyle ROUTINE
!|
!| This routine create all the styles to be shared in this window
!| It`s called after the window open
!|
!---------------------------------------------------------------------------

ThisWindow.Ask PROCEDURE

  CODE
  CASE SELF.Request                                        ! Configure the action message text
  OF ViewRecord
    ActionMessage = 'View Record'
  OF InsertRecord
    ActionMessage = 'Record Will Be Added'
  OF ChangeRecord
    GlobalErrors.Throw(Msg:UpdateIllegal)
    RETURN
  END
  QuickWindow{PROP:Text} = ActionMessage                   ! Display status message in title bar
  PARENT.Ask


ThisWindow.Init PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  GlobalErrors.SetProcedureName('UpdateFiles')
  SELF.Request = GlobalRequest                             ! Store the incoming request
  ReturnValue = PARENT.Init()
  IF ReturnValue THEN RETURN ReturnValue.
  SELF.FirstField = ?Files:PathName:Prompt
  SELF.VCRRequest &= VCRRequest
  SELF.Errors &= GlobalErrors                              ! Set this windows ErrorManager to the global ErrorManager
  SELF.AddItem(Toolbar)
  CLEAR(GlobalRequest)                                     ! Clear GlobalRequest after storing locally
  CLEAR(GlobalResponse)
  SELF.HistoryKey = CtrlH
  SELF.AddHistoryFile(Files:Record,History::Files:Record)
  SELF.AddHistoryField(?Files:Pathpt2,4)
  SELF.AddHistoryField(?Files:Type,6)
  SELF.AddHistoryField(?Files:Filename,5)
  SELF.AddHistoryField(?Files:Nr,1)
  SELF.AddHistoryField(?Files:ProNr,2)
  SELF.AddUpdateFile(Access:Files)
  SELF.AddItem(?Cancel,RequestCancelled)                   ! Add the cancel control to the window manager
  Relate:Files.SetOpenRelated()
  Relate:Files.Open                                        ! File Files used by this procedure, so make sure it's RelationManager is open
  SELF.FilesOpened = True
  SELF.Primary &= Relate:Files
  IF SELF.Request = ViewRecord AND NOT SELF.BatchProcessing ! Setup actions for ViewOnly Mode
    SELF.InsertAction = Insert:None
    SELF.DeleteAction = Delete:None
    SELF.ChangeAction = Change:None
    SELF.CancelAction = Cancel:Cancel
    SELF.OkControl = 0
  ELSE
    SELF.ChangeAction = Change:None                        ! Changes not allowed
    SELF.CancelAction = Cancel:Cancel+Cancel:Query         ! Confirm cancel
    SELF.OkControl = ?OK
    IF SELF.PrimeUpdate() THEN RETURN Level:Notify.
  END
  SELF.Open(QuickWindow)                                   ! Open window
  !Setting the LineHeight for every control of type LIST/DROP or COMBO in the window using the global setting.
  Do DefineListboxStyle
  IF SELF.Request = ViewRecord                             ! Configure controls for View Only mode
    ?Files:Pathpt2{PROP:ReadOnly} = True
    ?Files:Type{PROP:ReadOnly} = True
    ?Files:Filename{PROP:ReadOnly} = True
    ?Pat:LookupPath{PROP:ReadOnly} = True
    ?Files:Nr{PROP:ReadOnly} = True
    ?Files:ProNr{PROP:ReadOnly} = True
  END
  Resizer.Init(AppStrategy:Surface,Resize:SetMinSize)      ! Controls like list boxes will resize, whilst controls like buttons will move
  SELF.AddItem(Resizer)                                    ! Add resizer to window manager
  INIMgr.Fetch('UpdateFiles',QuickWindow)                  ! Restore window settings from non-volatile store
  Resizer.Resize                                           ! Reset required after window size altered by INI manager
  SELF.SetAlerts()
  RETURN ReturnValue


ThisWindow.Kill PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  ReturnValue = PARENT.Kill()
  IF ReturnValue THEN RETURN ReturnValue.
  IF SELF.FilesOpened
    Relate:Files.Close
  END
  IF SELF.Opened
    INIMgr.Update('UpdateFiles',QuickWindow)               ! Save window data to non-volatile store
  END
  GlobalErrors.SetProcedureName
  RETURN ReturnValue


ThisWindow.Reset PROCEDURE(BYTE Force=0)

  CODE
  SELF.ForcedReset += Force
  IF QuickWindow{Prop:AcceptAll} THEN RETURN.
  Pat:Nr = Files:Pathnum                                   ! Assign linking field value
  Access:Paths.Fetch(Pat:NrKey)
  PARENT.Reset(Force)


ThisWindow.Run PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  ReturnValue = PARENT.Run()
  IF SELF.Request = ViewRecord                             ! In View Only mode always signal RequestCancelled
    ReturnValue = RequestCancelled
  END
  RETURN ReturnValue


ThisWindow.TakeAccepted PROCEDURE

ReturnValue          BYTE,AUTO

Looped BYTE
  CODE
  LOOP                                                     ! This method receive all EVENT:Accepted's
    IF Looped
      RETURN Level:Notify
    ELSE
      Looped = 1
    END
  ReturnValue = PARENT.TakeAccepted()
    CASE ACCEPTED()
    OF ?OK
      ThisWindow.Update()
      IF SELF.Request = ViewRecord AND NOT SELF.BatchProcessing THEN
         POST(EVENT:CloseWindow)
      END
    END
    RETURN ReturnValue
  END
  ReturnValue = Level:Fatal
  RETURN ReturnValue


ThisWindow.TakeWindowEvent PROCEDURE

ReturnValue          BYTE,AUTO

Looped BYTE
  CODE
  LOOP                                                     ! This method receives all window specific events
    IF Looped
      RETURN Level:Notify
    ELSE
      Looped = 1
    END
    CASE EVENT()
    OF EVENT:CloseDown
      IF GLO:CleanCloseDown
         SELF.CancelAction = Cancel:Cancel
      END
    END
  ReturnValue = PARENT.TakeWindowEvent()
    RETURN ReturnValue
  END
  ReturnValue = Level:Fatal
  RETURN ReturnValue


Resizer.Init PROCEDURE(BYTE AppStrategy=AppStrategy:Resize,BYTE SetWindowMinSize=False,BYTE SetWindowMaxSize=False)


  CODE
  PARENT.Init(AppStrategy,SetWindowMinSize,SetWindowMaxSize)
  SELF.SetParentDefaults()                                 ! Calculate default control parent-child relationships based upon their positions on the window

!!! <summary>
!!! Generated from procedure template - Source
!!! scans given dir and adds files to files.tps
!!! </summary>
ScanDir              PROCEDURE  (STRING par:dir,LONG par:project) ! Declare Procedure
localdir             CSTRING(255)                          !
DirFiles QUEUE(File:queue),PRE(DirFIL)    !Inherit exact declaration of File:queue
 
        END
 
LP      LONG
Recs    LONG
 
 

  CODE
    localdir = par:dir 
                
    if right(par:dir,1) <> '\' 
        localdir = localdir & '\'
    .

    paths_pathlen# = len(Pat:LookupPath)

    SETCURSOR(CURSOR:Wait)

    set(files)
    previous(files)

    recordcounter# = Files:Nr +1

    lock(files)
        

    DIRECTORY(DirFiles,clip(localdir) & '*.*',ff_:DIRECTORY)   !Get all files and directories
                 
    Recs = RECORDS(DirFiles)

    counter# = 0
                 
    LOOP LP = Recs TO 1 BY -1
                    
        GET(DirFiles,LP)
                 
        if DirFIL:ShortName = '..' OR DirFIL:ShortName = '.' then cycle.  !Let sub-directory entries stay
                    
        IF BAND(DirFIL:Attrib,ff_:DIRECTORY)
           !rekursiv aufrufen
   !   stop('parameter: ' & localdir & ' rekursiv: ' & clip(localdir) & clip(DirFIL:name)) 
            build(files)
            if errorcode() and errorcode() <> 40 
                message('error in build: ' & error())
            END            
            
            unlock(files)
            result# = ScanDir(clip(localdir) & clip(DirFIL:name),par:project)
            counter# += result#
            recordcounter# += result#
            LOCK(files)
                       
            CYCLE
        END

        counter# +=1

        pathlen# = len(clip(DirFIL:name))
        dotpos# = instring('.',DirFIL:name,-1,pathlen#)  !get the last backslash
        extension" = SUB(DirFIL:name,dotpos#,pathlen# - dotpos# +1)
            
     !  stop(extension")
            
        if clip(extension") <> '.h' and clip(extension") <> '.ino' THEN cycle.

        Files:Nr = recordcounter#
        Files:ProNr = par:project
        Files:Pathnum = Pat:Nr
        Files:Pathpt2 = sub(localdir,paths_pathlen#+1,pathlen# - paths_pathlen#)
        Files:Filename = DirFIL:name
        Files:Type = extension"
        Append(Files)
        errc# = errorcode()
        if errorcode() and errorcode() <> 40 
            message(errorfile() & ':' & error())
            break
        END
        recordcounter# +=1
                    
        DELETE(DirFiles)                        !Get rid of all other entries
                 

    END


    build(files)
    if errorcode() and errorcode() <> 40 
        message(error())
    END
    unlock(files)

    SETCURSOR(CURSOR:Arrow)
         
    return(counter#)
!!! <summary>
!!! Generated from procedure template - Source
!!! scans lines in given file
!!! </summary>
scan_in_file         PROCEDURE  (STRING par:file)          ! Declare Procedure
Line_nr              LONG                                  !
max_depth            LONG                                  !
position_in_file     STRING(260)                           !
thisASCIIFile       FILE,DRIVER('ASCII'),PRE(tASC),BINDABLE,THREAD !read the files      
Record                  RECORD,PRE()
Line                        STRING(255)                    !                    
                        END
                    END 



Fi1                 FILE,DRIVER('ASCII'),PRE(Fi1),BINDABLE,THREAD !read the files      
Record                  RECORD,PRE()
Line                        STRING(255)                    !                    
                        END
                    END 

Fi2                 FILE,DRIVER('ASCII'),PRE(Fi2),BINDABLE,THREAD !read the files      
Record                  RECORD,PRE()
Line                        STRING(255)                    !                    
                        END
                    END 

Fi3                 FILE,DRIVER('ASCII'),PRE(Fi3),BINDABLE,THREAD !read the files      
Record                  RECORD,PRE()
Line                        STRING(255)                    !                    
                        END
                    END 

  CODE
    ThisASCIIFile{Prop:Name} = par:file

    if RIGHT(par:file,2) = '.h'
        imp:eor# = 3
    ELSE
        imp:eor# = 2
    END

    EXECUTE imp:eor#
        EOR" =  SEND(ThisAsciiFile, 'ENDOFRECORD = 1,13')  
        EOR" =  SEND(ThisAsciiFile, 'ENDOFRECORD = 2,13,10')   
        EOR" =  SEND(ThisAsciiFile, 'ENDOFRECORD = 1,10')  
    END

  !  stop('Öffne' & glo:depth & ' eor:' & imp:eor# & ', ' & eor" & par:file)

  !  glo:messagestring = glo:messagestring & '<13,10>' & par:file
    post(EVENT:Notify,,glo:messagethread,1)



    OPEN(thisASCIIFile,ReadOnly + DenyNone)
    if errorcode()
        message(error() & ' ' & ThisASCIIFile{Prop:Name})
        RETURN -1
    END

    max_depth = 5
    glo:depth +=1
    Line_nr = 0
    counter# = 0

    set(ThisASCIIFile)
    LOOP
                            
        next(ThisASCIIFile)
        if ERRORCODE()
   !         if Line_nr < 3 then stop('wrong EndOfRecord??').
            break
        END
        Line_nr +=1
                     !  stop('in Line: ' & Line_nr & ' ' & LEFT(tASC:Line,30))                 
        if left(tASC:Line,8) = '#include'

            lt_pos# = instring('<',tASC:Line,1,7)
            lt_flag# = TRUE
            if lt_pos# < 1
                lt_pos# = instring('"',tASC:Line,1,7)
                lt_flag# = FALSE
            .
            if lt_pos# < 1
                MQ:Line = 'wrong include:' & tASC:Line
            ELSE
                end_pos# = instring('.h',tASC:Line,1,lt_pos#)
                MQ:Line = SUB(tASC:Line,lt_pos# + 1,end_pos#+1 -lt_pos#)
                Files:Filename = MQ:Line
                set(Files:FilenameKey,Files:FilenameKey)
                LOOP
                    next(Files)
                    if ERRORCODE()then break.
                    if clip(Files:Filename) <> left(MQ:Line,len(clip(Files:Filename))) then break.
                    if Files:ProNr <> Pro:Nr then CYCLE.
                    MQ:Line = clip(MQ:Line) & '<9>//' & Files:Pathpt2
                                        
                    Pat:Nr = Files:Pathnum
                    get(Paths,Pat:NrKey)
                    if ~ERRORCODE()
                 !       if glo:depth = 1 THEN    stop('vorherLine:' & Line_nr & ' ' & left(tASC:Line,40) & ThisASCIIFile{Prop:Name}).
                        do append2queue
                        
                        if glo:depth < max_depth
                            close(thisASCIIFile)

                            scan_in_file(clip(Pat:LookupPath) & clip(Files:Pathpt2) & clip(Files:Filename))     !rekursiv
                            EXECUTE imp:eor#
                                EOR" =  SEND(ThisAsciiFile, 'ENDOFRECORD = 1,13')  
                                EOR" =  SEND(ThisAsciiFile, 'ENDOFRECORD = 2,13,10')   
                                EOR" =  SEND(ThisAsciiFile, 'ENDOFRECORD = 1,10') 
                            END 
                            
                            ThisASCIIFile{Prop:Name} = par:file
                            OPEN(thisASCIIFile,ReadOnly + DenyNone)
                            set(thisASCIIFile)
                            LOOP Line_nr TIMES
                                next(thisASCIIFile)
                                if errorcode()
                                    stop('Problem in Reset')
                                    break
                                END
                            END
                        END                                        
                  !      if glo:depth = 1 THEN stop('nachher Line:' & Line_nr & ' '  & left(tASC:Line,40)).                            
                        

                    END                     
                                       
                                        
                                        
                END
                                    
                                    
                                    
            END
            
            counter# +=1

            !do append2queue
           
                              
        END
                            
    END

    close(ThisASCIIFile)

     !   stop(glo:depth & ' ' & records(MemQueue))

    glo:depth -=1

    RETURN counter#


append2queue        ROUTINE
    
    sic:line = MQ:Line
    MQ:depth = glo:depth
            
            !get(MemQueue,MQ:Line,MQ:depth)
    get(MemQueue,MQ:Line,MQ:depth)
    if ERRORCODE()
        MQ:Line = sic:line
        MQ:depth = glo:depth
        MQ:Filenr = Files:Nr
        add(MemQueue)
    END
!!! <summary>
!!! Generated from procedure template - Window
!!! Window
!!! </summary>
Messages PROCEDURE 

QuickWindow          WINDOW('Info'),AT(,,530,370),FONT('Microsoft Sans Serif',8,,FONT:regular,CHARSET:DEFAULT), |
  NOFRAME,AUTO,CENTER,ICON(ICON:Asterisk),IMM,MAX,MDI,HLP('Messages'),SYSTEM,TIMER(500),WALLPAPER('media\Hint' & |
  'ergrund2018_verlauf_2000.png')
                       BUTTON('&OK'),AT(233,356,49,14),USE(?Ok),COLOR(COLOR:Black),HIDE,MSG('Accept operation'),TIP('Accept Operation')
                       BUTTON('&Cancel'),AT(2,399,49,6),USE(?Cancel),COLOR(COLOR:Black),HIDE,MSG('Cancel Operation'), |
  TIP('Cancel Operation')
                       BUTTON('&Help'),AT(2,386,49,6),USE(?Help),COLOR(COLOR:Black),HIDE,MSG('See Help Window'),STD(STD:Help), |
  TIP('See Help Window')
                       TEXT,AT(3,3,525,364),USE(glo:messagestring),FONT('Arial Narrow',7,00228B22h,,CHARSET:ANSI), |
  HVSCROLL,READONLY,SKIP,TRN
                     END

ThisWindow           CLASS(WindowManager)
Init                   PROCEDURE(),BYTE,PROC,DERIVED
Kill                   PROCEDURE(),BYTE,PROC,DERIVED
TakeWindowEvent        PROCEDURE(),BYTE,PROC,DERIVED
                     END

Toolbar              ToolbarClass
Resizer              CLASS(WindowResizeClass)
Init                   PROCEDURE(BYTE AppStrategy=AppStrategy:Resize,BYTE SetWindowMinSize=False,BYTE SetWindowMaxSize=False)
                     END


  CODE
  GlobalResponse = ThisWindow.Run()                        ! Opens the window and starts an Accept Loop

!---------------------------------------------------------------------------
DefineListboxStyle ROUTINE
!|
!| This routine create all the styles to be shared in this window
!| It`s called after the window open
!|
!---------------------------------------------------------------------------

ThisWindow.Init PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  GlobalErrors.SetProcedureName('Messages')
  SELF.Request = GlobalRequest                             ! Store the incoming request
  ReturnValue = PARENT.Init()
  IF ReturnValue THEN RETURN ReturnValue.
  SELF.FirstField = ?Ok
  SELF.VCRRequest &= VCRRequest
  SELF.Errors &= GlobalErrors                              ! Set this windows ErrorManager to the global ErrorManager
  SELF.AddItem(Toolbar)
  CLEAR(GlobalRequest)                                     ! Clear GlobalRequest after storing locally
  CLEAR(GlobalResponse)
  IF SELF.Request = SelectRecord
     SELF.AddItem(?Ok,RequestCancelled)                    ! Add the close control to the window manger
  ELSE
     SELF.AddItem(?Ok,RequestCompleted)                    ! Add the close control to the window manger
  END
  SELF.AddItem(?Cancel,RequestCancelled)                   ! Add the cancel control to the window manager
  SELF.Open(QuickWindow)                                   ! Open window
  !Setting the LineHeight for every control of type LIST/DROP or COMBO in the window using the global setting.
  Do DefineListboxStyle
  Resizer.Init(AppStrategy:Surface,Resize:SetMinSize)      ! Controls like list boxes will resize, whilst controls like buttons will move
  SELF.AddItem(Resizer)                                    ! Add resizer to window manager
  INIMgr.Fetch('Messages',QuickWindow)                     ! Restore window settings from non-volatile store
  Resizer.Resize                                           ! Reset required after window size altered by INI manager
  SELF.SetAlerts()
        glo:messagewindowopen = TRUE  
  RETURN ReturnValue


ThisWindow.Kill PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  ReturnValue = PARENT.Kill()
  IF ReturnValue THEN RETURN ReturnValue.
  IF SELF.Opened
    INIMgr.Update('Messages',QuickWindow)                  ! Save window data to non-volatile store
  END
  GlobalErrors.SetProcedureName
  glo:messagewindowopen = FALSE
  RETURN ReturnValue


ThisWindow.TakeWindowEvent PROCEDURE

ReturnValue          BYTE,AUTO

Looped BYTE
  CODE
  LOOP                                                     ! This method receives all window specific events
    IF Looped
      RETURN Level:Notify
    ELSE
      Looped = 1
    END
    CASE EVENT()
    OF EVENT:CloseDown
      IF GLO:CleanCloseDown
         SELF.CancelAction = Cancel:Cancel
      END
    OF EVENT:Notify
        DISPLAY
    END
  ReturnValue = PARENT.TakeWindowEvent()
    CASE EVENT()
    OF EVENT:CloseWindow
      glo:messagethread = 0
    OF EVENT:Notify
      DISPLAY
      
    OF EVENT:Timer
      DISPLAY
    END
    RETURN ReturnValue
  END
  ReturnValue = Level:Fatal
  RETURN ReturnValue


Resizer.Init PROCEDURE(BYTE AppStrategy=AppStrategy:Resize,BYTE SetWindowMinSize=False,BYTE SetWindowMaxSize=False)


  CODE
  PARENT.Init(AppStrategy,SetWindowMinSize,SetWindowMaxSize)
  SELF.SetParentDefaults()                                 ! Calculate default control parent-child relationships based upon their positions on the window

!!! <summary>
!!! Generated from procedure template - Window
!!! the Helper
!!! </summary>
Wizard PROCEDURE 

loc:asciifilename    CSTRING(255)                          !
loc:search_browser   CSTRING(255)                          !
loc:keyboard_inject  CSTRING(255)                          !
skiptoleft_cb        BYTE                                  !1= skip til next curly brace/ 0= right
loc:dc_action        BYTE                                  !1 = run editor; 2 = setclipboard, 3 = keyboard inject, else scanstructur
loc:dc_mode          LONG                                  !
Line_nr              LONG                                  !
search               CSTRING(31)                           !
sic:filenr           LONG                                  !
sic:class            CSTRING(81)                           !
skip_protected       BYTE                                  !
sic:depth            LONG                                  !
ResultQ              QUEUE,PRE(RQ)                         !
Line                 CSTRING(255)                          !
Filenr               LONG                                  !
depth                LONG                                  !
class                CSTRING(81)                           !
                     END                                   !
localmessage         CSTRING(1000)                         !
QuickWindow          WINDOW('Wizard'),AT(,,435,362),FONT('Microsoft Sans Serif',8,,FONT:regular,CHARSET:DEFAULT), |
  NOFRAME,AUTO,CENTER,COLOR(00908070h),ICON('media\OH.ico'),GRAY,IMM,HLP('Wizard'),TIMER(100)
                       BUTTON('&Close'),AT(372,335,49,22),USE(?Ok),LEFT,ICON(ICON:Cross),FLAT,MSG('Accept operation'), |
  TIP('Accept Operation'),TRN
                       BUTTON('&Cancel'),AT(304,2,49,14),USE(?Cancel),HIDE,MSG('Cancel Operation'),TIP('Cancel Operation')
                       BUTTON('&Help'),AT(357,2,49,14),USE(?Help),HIDE,MSG('See Help Window'),STD(STD:Help),TIP('See Help Window')
                       ENTRY(@s30),AT(15,5,406),USE(search),FONT(,20),UPR,COLOR(00C0FFC0h)
                       TEXT,AT(15,311,406,16),USE(localmessage),FONT(,,00E1E4FFh,FONT:regular+FONT:italic),READONLY, |
  SKIP,TRN
                       LIST,AT(15,32,406,274),USE(?LIST1),HVSCROLL,ALRT(MouseLeft2),DRAGID('drag_wont_work'),DROPID('~Text', |
  '~TEXT'),FORMAT('292L(2)|M~Line~@s254@27L(2)|M~Filenr~L(1)@n_5@22L(2)|M~depth~L(1)@n_' & |
  '3@320L(2)|M~class~@s80@'),FROM(ResultQ)
                       STRING('drag does keyboard injection / doubleclick does selected action'),AT(2,56,11,206), |
  USE(?STRING1),FONT(,,00A9A9A9h,FONT:regular+FONT:italic),ANGLE(900)
                       BUTTON('open file in editor'),AT(17,335,,22),USE(?BUTTON_editor),LEFT,ICON(ICON:Child),FLAT, |
  TIP('as of filenr')
                       BUTTON('on doubleclick: copy to clipboard'),AT(222,335,128,22),USE(?BUTTONdc_mode),FONT(,, |
  00AAE8EEh,FONT:regular+FONT:italic),TIP('action on doubleclick: <0DH,0AH>-open file (' & |
  'in external editor)<0DH,0AH>-copy to clipboard<0DH,0AH>-keyboard injection'),TRN
                       BUTTON('WebSearch'),AT(121,335,89,22),USE(?BUTTONSearchEngine),LEFT,ICON(ICON:Connect),FLAT, |
  TRN
                       STRING('search'),AT(2,2,11,28),USE(?STRING1:2),FONT(,,00A9A9A9h,FONT:regular+FONT:italic), |
  ANGLE(900),COLOR(00908070h)
                     END

ThisWindow           CLASS(WindowManager)
Init                   PROCEDURE(),BYTE,PROC,DERIVED
Kill                   PROCEDURE(),BYTE,PROC,DERIVED
TakeAccepted           PROCEDURE(),BYTE,PROC,DERIVED
TakeFieldEvent         PROCEDURE(),BYTE,PROC,DERIVED
TakeWindowEvent        PROCEDURE(),BYTE,PROC,DERIVED
                     END

Toolbar              ToolbarClass
Resizer              CLASS(WindowResizeClass)
Init                   PROCEDURE(BYTE AppStrategy=AppStrategy:Resize,BYTE SetWindowMinSize=False,BYTE SetWindowMaxSize=False)
                     END

ASCIIFile2       FILE,DRIVER('ASCII'),PRE(tASC2),BINDABLE,THREAD !read the files      
Record                  RECORD,PRE()
Line                        STRING(255)                    !                    
                        END
                    END 

DC_MODE:CLIPBOARD EQUATE(1)
DC_MODE:OPENFILE  EQUATE(2)
DC_MODE:KEYBOARDINJECT EQUATE(3)

DC_ACTION:NOACTION EQUATE(0)
DC_ACTION:CLIPBOARD EQUATE(1)
DC_ACTION:OPENFILE  EQUATE(2)
DC_ACTION:KEYBOARDINJECT EQUATE(3)


  CODE
  GlobalResponse = ThisWindow.Run()                        ! Opens the window and starts an Accept Loop

!---------------------------------------------------------------------------
DefineListboxStyle ROUTINE
!|
!| This routine create all the styles to be shared in this window
!| It`s called after the window open
!|
!---------------------------------------------------------------------------
get_file            ROUTINE
   
    
    thechoice# = CHOICE(?LIST1)  ! Get current selection in list box
   
    GET(ResultQ, thechoice#)
    
    if  loc:dc_action = DC_ACTION:CLIPBOARD   
        setclipboard(clip(RQ:Line))
        EXIT
    END
    
    if  loc:dc_action = DC_ACTION:KEYBOARDINJECT
        loc:keyboard_inject = left(clip(RQ:Line))
        
        imp:kilen# = len(left(loc:keyboard_inject))
        
        if left(loc:keyboard_inject,7) = 'virtual' 
            loc:keyboard_inject = left(sub(left(loc:keyboard_inject),8,imp:kilen# -8))
        .
        if left(loc:keyboard_inject,4) = 'void' 
            loc:keyboard_inject = sub(left(loc:keyboard_inject),5,imp:kilen# -5)
  !    stop('void: ' & loc:keyboard_inject)            
        .
        if INSTRING(');',loc:keyboard_inject,1,1) then loc:keyboard_inject = left(loc:keyboard_inject,INSTRING(');',loc:keyboard_inject,1,1) ).
        EXIT
    END
    
    
    
    Files:Nr = RQ:Filenr
    get(Files,Files:NrKey)
    if errorcode()
        localmessage = 'could not get file'
        DISPLAY
        EXIT
    END
    
    Pat:Nr = Files:Pathnum
    get(Paths,Pat:NrKey)
    if ~ERRORCODE()
        loc:asciifilename = clip(Pat:LookupPath) & clip(Files:Pathpt2) & '' & clip(Files:Filename)
        case loc:dc_action 
        of DC_ACTION:OPENFILE
            run('"' & loc:asciifilename & '"')
        ELSE    !DC_ACTION:NOACTION (no Doubleclick Action)
            sic:filenr  = RQ:Filenr
            sic:depth   = RQ:depth
            do scan_structur
        END
        
    ELSE
        localmessage = 'Path not available'
    END 
    
    DISPLAY    


scan_structur       ROUTINE
    
    ASCIIFile2{Prop:Name} = loc:asciifilename
    
    skip_protected = FALSE  !not for use as a switch, its just a flag
    
    if RIGHT(loc:asciifilename,2) = '.h'
        imp:eor# = 3
    ELSE
        imp:eor# = 2
    END

    EXECUTE imp:eor#
        EOR" =  SEND(AsciiFile2, 'ENDOFRECORD = 1,13')  
        EOR" =  SEND(AsciiFile2, 'ENDOFRECORD = 2,13,10')   
        EOR" =  SEND(AsciiFile2, 'ENDOFRECORD = 1,10')  
    END

    post(EVENT:Notify,,glo:messagethread,1)

    OPEN(ASCIIFile2,ReadOnly + DenyNone)
    if errorcode()
        message(error() & ' ' & ASCIIFile2{Prop:Name})
        EXIT
    END

    Line_nr = 0
    counter# = 0

    set(ASCIIFile2)
    LOOP
                            
        next(ASCIIFile2)
        if ERRORCODE()
   !         if Line_nr < 3 then stop('wrong EndOfRecord??').
            break
        END
        
        Line_nr +=1
        level# = 1
        
                     !  stop('in Line: ' & Line_nr & ' ' & LEFT(tASC:Line,30))                 
        if left(tASC2:Line,8) = '#include' then cycle.
        if len(clip(tASC2:Line)) < 1 then cycle.
        if left(tASC2:Line,1) = '/' then cycle.
        
        if left(tASC2:Line,1) = '}'
            level# -=1
            if level# = 1
                sic:class = ''
            ELSE
                sic:class = sic:class & '?'
            END
            cycle
        END
        

        if left(tASC2:Line,7) = 'public:'
            skip_protected = FALSE
            cycle
        END
        if skip_protected OR left(tASC2:Line,10) = 'protected:'
            skip_protected = TRUE
            cycle
        END
        
        line_len# = len(tASC2:Line)

        if left(tASC2:Line,9) = 'namespace'
            skiptoleft_cb = 0
            do skip_this_level
        END
        
        
        if left(tASC2:Line,5) = 'class'
            if right(tASC2:Line,1) = ';' then CYCLE.    !skip forward declarations to keep it simple
            RQ:Line = tASC2:Line
            RQ:Filenr = sic:filenr
            RQ:depth = sic:depth
            RQ:class = SUB(tASC2:Line,7,line_len# - 8)
            add(ResultQ)
            sic:class = RQ:class
            
            level# +=1
            skiptoleft_cb = 1
            do skip_this_level
            CYCLE
        END
        
        semi_pos# = INSTRING(');',tASC2:Line,1,1)
        if semi_pos# < 1 then CYCLE.
        
        RQ:Line = tASC2:Line
        RQ:Filenr = sic:filenr
        RQ:depth = sic:depth
        RQ:class = sic:class
        add(ResultQ)
        
        CYCLE
        
        counter# +=1
            
    END

    close(ASCIIFile2)
    

skip_this_level     ROUTINE
    
    loop 30 TIMES   !skip to next left/right curly brace
        if skiptoleft_cb = 1
            if instring('{{',tASC2:Line,1,1) THEN break.
        ELSE
            if instring('}',tASC2:Line,1,1) THEN break.
        END
        
        next(ASCIIFile2)
        if ERRORCODE() then BREAK.
    END
    
    EXIT
    
    

    

ThisWindow.Init PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  GlobalErrors.SetProcedureName('Wizard')
  SELF.Request = GlobalRequest                             ! Store the incoming request
  ReturnValue = PARENT.Init()
  IF ReturnValue THEN RETURN ReturnValue.
  SELF.FirstField = ?Ok
  SELF.VCRRequest &= VCRRequest
  SELF.Errors &= GlobalErrors                              ! Set this windows ErrorManager to the global ErrorManager
  SELF.AddItem(Toolbar)
  CLEAR(GlobalRequest)                                     ! Clear GlobalRequest after storing locally
  CLEAR(GlobalResponse)
  loc:dc_mode = DC_MODE:CLIPBOARD
  IF SELF.Request = SelectRecord
     SELF.AddItem(?Ok,RequestCancelled)                    ! Add the close control to the window manger
  ELSE
     SELF.AddItem(?Ok,RequestCompleted)                    ! Add the close control to the window manger
  END
  SELF.AddItem(?Cancel,RequestCancelled)                   ! Add the cancel control to the window manager
  Relate:Files.SetOpenRelated()
  Relate:Files.Open                                        ! File Files used by this procedure, so make sure it's RelationManager is open
  Relate:Settings.Open                                     ! File Settings used by this procedure, so make sure it's RelationManager is open
  Access:Paths.UseFile                                     ! File referenced in 'Other Files' so need to inform it's FileManager
  SELF.FilesOpened = True
  SELF.Open(QuickWindow)                                   ! Open window
  !Setting the LineHeight for every control of type LIST/DROP or COMBO in the window using the global setting.
  ?LIST1{PROP:LineHeight} = 12
  Do DefineListboxStyle
  QuickWindow{PROP:MaxWidth} = 800                         ! Restrict the maximum window width
  QuickWindow{PROP:MaxHeight} = 800                        ! Restrict the maximum window height
  Resizer.Init(AppStrategy:Surface,Resize:SetMinSize)      ! Controls like list boxes will resize, whilst controls like buttons will move
  SELF.AddItem(Resizer)                                    ! Add resizer to window manager
  INIMgr.Fetch('Wizard',QuickWindow)                       ! Restore window settings from non-volatile store
  Resizer.Resize                                           ! Reset required after window size altered by INI manager
  SELF.SetAlerts()
  RETURN ReturnValue


ThisWindow.Kill PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  ReturnValue = PARENT.Kill()
  IF ReturnValue THEN RETURN ReturnValue.
  IF SELF.FilesOpened
    Relate:Files.Close
    Relate:Settings.Close
  END
  IF SELF.Opened
    INIMgr.Update('Wizard',QuickWindow)                    ! Save window data to non-volatile store
  END
  GlobalErrors.SetProcedureName
  RETURN ReturnValue


ThisWindow.TakeAccepted PROCEDURE

ReturnValue          BYTE,AUTO

Looped BYTE
  CODE
  LOOP                                                     ! This method receive all EVENT:Accepted's
    IF Looped
      RETURN Level:Notify
    ELSE
      Looped = 1
    END
  ReturnValue = PARENT.TakeAccepted()
    CASE ACCEPTED()
    OF ?search
      free(ResultQ)
      
      search = upper(search)
      localmessage = ''
      
      DISPLAY
      
      LOOP i# = 1 to records(MemQueue)
          get(MemQueue,i#)
      
          slashpos# = instring('//', MQ:Line,1,1)
          if slashpos# =< 1 then slashpos# = len(clip(MQ:Line)).
          if instring(search, upper(left(MQ:Line,slashpos#)),1,1)
              RQ:Line = MQ:Line
              RQ:depth = MQ:depth
              RQ:Filenr = MQ:Filenr
              add(ResultQ)
          END
      END
      
      res_recs# = records(ResultQ)
      if res_recs#
          LOOP ii# = 1 to res_recs#
              get(ResultQ,ii#)
      
              if INSTRING('.h',RQ:Line,1,1)
                  loc:dc_action = DC_ACTION:NOACTION
                  do get_file
              END
              
             localmessage = ii# & ' file(s) found..'     
      
          END
      ELSE
          localmessage = 'no results for ' & search & '<13,10>'
          
      END
      
      DISPLAY
      
      
    OF ?BUTTON_editor
      ThisWindow.Update()
          loc:dc_action = DC_ACTION:OPENFILE   !run editor
          do get_file      
    OF ?BUTTONdc_mode
      ThisWindow.Update()
          CASE    loc:dc_mode
          OF DC_MODE:CLIPBOARD
              loc:dc_mode = DC_MODE:OPENFILE
              ?BUTTONdc_mode{PROP:Text} = 'doubleclick action: open file'
          OF  2 
              loc:dc_mode = DC_MODE:KEYBOARDINJECT
              ?BUTTONdc_mode{PROP:Text} = 'doubleclick action: keyboard injection'
          OF 3
              loc:dc_mode = DC_MODE:CLIPBOARD
              ?BUTTONdc_mode{PROP:Text} = 'doubleclick action: copy to clipboard'        
          END
      
          DISPLAY
    OF ?BUTTONSearchEngine
      ThisWindow.Update()
      thechoice# = CHOICE(?LIST1)  ! Get current selection in list box
         
      GET(ResultQ, thechoice#)
      
      Set:Nr = 2
      get(settings,Set:NrKey)
      if ~ERRORCODE()
          loc:search_browser = clip(Set:Content)
          
          Set:Nr = 3
          get(settings,Set:NrKey)
          if ~ERRORCODE()
              !in set:content is something like https://google.de/search?q=arduino
              run('"' & loc:search_browser & '" "' & clip(Set:Content) & '%20' & clip(RQ:class) & '%20class"')        
              
          else 
             localmessage = 'no search engine url in main menu:file:settings' 
          END
          
      ELSE
          localmessage = 'no browser set in main menu:file:settings'
      END
      
      
    END
    RETURN ReturnValue
  END
  ReturnValue = Level:Fatal
  RETURN ReturnValue


ThisWindow.TakeFieldEvent PROCEDURE

ReturnValue          BYTE,AUTO

Looped BYTE
  CODE
  LOOP                                                     ! This method receives all field specific events
    IF Looped
      RETURN Level:Notify
    ELSE
      Looped = 1
    END
  ReturnValue = PARENT.TakeFieldEvent()
  CASE FIELD()
  OF ?LIST1
    IF KEYCODE() = MouseLeft2
        !loc:dc_mode: clipboard / file / keyboard injection
        loc:keyboard_inject = ''
        
        case loc:dc_mode
        of DC_MODE:CLIPBOARD
            loc:dc_action = DC_ACTION:CLIPBOARD ! 1= run editor / 2= setclipboard
            do get_file 
            localmessage = 'copied to clipboard:' & CLIPBOARD()
        of DC_MODE:OPENFILE
            loc:dc_action = DC_ACTION:OPENFILE
            do get_file 
            localmessage = 'file opened:' & CLIPBOARD()
        of DC_MODE:KEYBOARDINJECT
            loc:dc_action = DC_ACTION:KEYBOARDINJECT
            do get_file 
            localmessage = 'armed for keyboard injection on clicking in target window:' & loc:keyboard_inject
            
        END
        
        
        
    END
    
    
    CASE EVENT()
    OF EVENT:Dragging
      thechoice# = CHOICE(?LIST1)  ! Get current selection in list box
         
      GET(ResultQ, thechoice#)
      SETDROPID(RQ:Line)
      
      loc:dc_action = DC_ACTION:KEYBOARDINJECT
      loc:keyboard_inject = clip(RQ:Line)
      
      !SETCLIPBOARD(RQ:Line)
        
    OF EVENT:Drag
      thechoice# = CHOICE(?LIST1)  ! Get current selection in list box
         
      GET(ResultQ, thechoice#)
      SETDROPID(RQ:Line)
      
          
    END
  END
    RETURN ReturnValue
  END
  ReturnValue = Level:Fatal
  RETURN ReturnValue


ThisWindow.TakeWindowEvent PROCEDURE

ReturnValue          BYTE,AUTO

Looped BYTE
  CODE
  LOOP                                                     ! This method receives all window specific events
    IF Looped
      RETURN Level:Notify
    ELSE
      Looped = 1
    END
    CASE EVENT()
    OF EVENT:CloseDown
      IF GLO:CleanCloseDown
         SELF.CancelAction = Cancel:Cancel
      END
    END
  ReturnValue = PARENT.TakeWindowEvent()
    CASE EVENT()
    OF EVENT:GainFocus
      select(?search)
    OF EVENT:LoseFocus
      if loc:dc_mode = DC_MODE:KEYBOARDINJECT  !keyboard injection
          if loc:dc_action = DC_ACTION:KEYBOARDINJECT
              localmessage = 'armed for injection...' & loc:keyboard_inject
         
              press(loc:keyboard_inject)      !    presskey(ShiftInsert)       !CtrlV
              loc:dc_action = DC_ACTION:NOACTION
          END
      END
    OF EVENT:OpenWindow
      select(?search)
    OF EVENT:Timer
      !ActiveThread# = SYSTEM{PROP:Active}
      !localmessage = 'Thread:' & ActiveThread#
      !DISPLAY
    END
    RETURN ReturnValue
  END
  ReturnValue = Level:Fatal
  RETURN ReturnValue


Resizer.Init PROCEDURE(BYTE AppStrategy=AppStrategy:Resize,BYTE SetWindowMinSize=False,BYTE SetWindowMaxSize=False)


  CODE
  PARENT.Init(AppStrategy,SetWindowMinSize,SetWindowMaxSize)
  SELF.SetParentDefaults()                                 ! Calculate default control parent-child relationships based upon their positions on the window

