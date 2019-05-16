

   MEMBER('ObjectHelper.clw')                              ! This is a MEMBER module


   INCLUDE('ABBROWSE.INC'),ONCE
   INCLUDE('ABPOPUP.INC'),ONCE
   INCLUDE('ABRESIZE.INC'),ONCE
   INCLUDE('ABTOOLBA.INC'),ONCE
   INCLUDE('ABWINDOW.INC'),ONCE
   INCLUDE('BRWEXT.INC'),ONCE
   INCLUDE('winext.inc'),ONCE

                     MAP
                       INCLUDE('OBJECTHELPER001.INC'),ONCE        !Local module procedure declarations
                       INCLUDE('OBJECTHELPER002.INC'),ONCE        !Req'd for module callout resolution
                     END


!!! <summary>
!!! Generated from procedure template - Frame
!!! Wizard Application for C:\Projekte\ObjectHelper\OH.dct
!!! </summary>
Main PROCEDURE 

AppFrame             APPLICATION('Object Helper 0.22b'),AT(,,563,373),FONT('Microsoft Sans Serif',8,,FONT:regular, |
  CHARSET:DEFAULT),RESIZE,CENTER,ICON('media\OH.ico'),MAX,SYSTEM,WALLPAPER('media\Hinte' & |
  'rgrund2018_verlauf_2000.png'),IMM
                       MENUBAR,USE(?Menubar)
                         MENU('&File'),USE(?FileMenu)
                           ITEM('&Printer'),USE(?PrintSetup),HIDE,MSG('Printer Settings'),STD(STD:PrintSetup)
                           ITEM('&Settings'),USE(?BrowseSettings),MSG('Browse Settings')
                           ITEM,USE(?SEPARATOR1),SEPARATOR
                           ITEM('E&xit'),USE(?Exit),MSG('Exit'),STD(STD:Close)
                         END
                         MENU('&Edit'),USE(?EditMenu),HIDE
                           ITEM('Cu&t'),USE(?Cut),MSG('Cut Selection To Clipboard'),STD(STD:Cut)
                           ITEM('&Copy'),USE(?Copy),MSG('Copy Selection To Clipboard'),STD(STD:Copy)
                           ITEM('&Paste'),USE(?Paste),MSG('Paste From Clipboard'),STD(STD:Paste)
                         END
                         ITEM('Projects'),USE(?BrowseProjects),FONT(,,,FONT:bold),MSG('Browse Projects')
                         MENU('&Browse'),USE(?BrowseMenu),HIDE
                           ITEM('Browse Files of Project'),USE(?BrowseFiles),MSG('Browse Projectfiles')
                         END
                       END
                     END

ThisWindow           CLASS(WindowManager)
Init                   PROCEDURE(),BYTE,PROC,DERIVED
Kill                   PROCEDURE(),BYTE,PROC,DERIVED
TakeAccepted           PROCEDURE(),BYTE,PROC,DERIVED
TakeEvent              PROCEDURE(),BYTE,PROC,DERIVED
TakeNotify             PROCEDURE(UNSIGNED NotifyCode,SIGNED Thread,LONG Parameter),BYTE,PROC,DERIVED
TakeWindowEvent        PROCEDURE(),BYTE,PROC,DERIVED
                     END

Toolbar              ToolbarClass
FrameExtension       CLASS(WindowExtenderClass)
TrayIconMouseLeft2     PROCEDURE(),DERIVED
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
Menu::Menubar ROUTINE                                      ! Code for menu items on ?Menubar
  CASE ACCEPTED()
  OF ?BrowseProjects
    START(BrowseProjects, 050000)
  END
Menu::FileMenu ROUTINE                                     ! Code for menu items on ?FileMenu
  CASE ACCEPTED()
  OF ?BrowseSettings
    START(BrowseSettings, 050000)
  END
Menu::EditMenu ROUTINE                                     ! Code for menu items on ?EditMenu
Menu::BrowseMenu ROUTINE                                   ! Code for menu items on ?BrowseMenu
  CASE ACCEPTED()
  OF ?BrowseFiles
    START(BrowseFiles, 050000)
  END

ThisWindow.Init PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  GlobalErrors.SetProcedureName('Main')
  GLO:CleanCloseDownMainThread = THREAD()
  SELF.Request = GlobalRequest                             ! Store the incoming request
  ReturnValue = PARENT.Init()
  IF ReturnValue THEN RETURN ReturnValue.
  SELF.FirstField = 1
  SELF.VCRRequest &= VCRRequest
  SELF.Errors &= GlobalErrors                              ! Set this windows ErrorManager to the global ErrorManager
  SELF.AddItem(Toolbar)
  CLEAR(GlobalRequest)                                     ! Clear GlobalRequest after storing locally
  CLEAR(GlobalResponse)
  Relate:Projects.SetOpenRelated()
  Relate:Projects.Open                                     ! File Projects used by this procedure, so make sure it's RelationManager is open
  Relate:Settings.Open                                     ! File Settings used by this procedure, so make sure it's RelationManager is open
  SELF.FilesOpened = True
  Set:Nr = 1
  get(Settings,Set:NrKey)
  if errorcode()
      Set:Nr = 1
      Set:Name = 'Last project'
      Set:Type = 1
      Set:Content = 0
      ADD(Settings)
  ELSE
      activeProject = Set:Content
      Pro:Nr = activeProject
      get(Projects,Pro:NrKey)
      if ~ERRORCODE() then activeProjectName = Pro:Name else activeProjectName = 'project not found'.
     ! stop(activeProjectName)
  END
  
  Set:Nr = 2
  get(Settings,Set:NrKey)
  if errorcode()
      Set:Nr = 2
      Set:Name = 'Browser an Search Engine'
      Set:Type = 2
      Set:Content = 'C:\Program Files (x86)\Google\Chrome\Application\chrome.exe'
      ADD(Settings)
  END
  
  Set:Nr = 3
  get(Settings,Set:NrKey)
  if errorcode()
      Set:Nr = 3
      Set:Name = 'Search Engine url'
      Set:Type = 2
      Set:Content = 'https://google.de/search?q=arduino'
      ADD(Settings)
  END
  
  SELF.Open(AppFrame)                                      ! Open window
  !Setting the LineHeight for every control of type LIST/DROP or COMBO in the window using the global setting.
  Do DefineListboxStyle
  FrameExtension.Init(AppFrame,1,1,0{PROP:Icon},'')
  INIMgr.Fetch('Main',AppFrame)                            ! Restore window settings from non-volatile store
  SELF.SetAlerts()
  !glo:messagethread = START(Messages, 050000)
  START(BrowseProjects, 050000)
      AppFrame{PROP:TabBarVisible}  = False
  RETURN ReturnValue


ThisWindow.Kill PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  ReturnValue = PARENT.Kill()
  IF ReturnValue THEN RETURN ReturnValue.
  IF SELF.FilesOpened
    Relate:Projects.Close
    Relate:Settings.Close
  END
  IF SELF.Opened
    INIMgr.Update('Main',AppFrame)                         ! Save window data to non-volatile store
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
    CASE ACCEPTED()
    ELSE
      DO Menu::Menubar                                     ! Process menu items on ?Menubar menu
      DO Menu::FileMenu                                    ! Process menu items on ?FileMenu menu
      DO Menu::EditMenu                                    ! Process menu items on ?EditMenu menu
      DO Menu::BrowseMenu                                  ! Process menu items on ?BrowseMenu menu
    END
  ReturnValue = PARENT.TakeAccepted()
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
    IF EVENT()
       FrameExtension.TakeEvent()
    END
  ReturnValue = PARENT.TakeEvent()
    RETURN ReturnValue
  END
  ReturnValue = Level:Fatal
  RETURN ReturnValue


ThisWindow.TakeNotify PROCEDURE(UNSIGNED NotifyCode,SIGNED Thread,LONG Parameter)

ReturnValue          BYTE,AUTO

  CODE
  IF NotifyCode = NOTIFY:CloseDown
     POST(EVENT:CloseDown)
  END
  ReturnValue = PARENT.TakeNotify(NotifyCode,Thread,Parameter)
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
  ReturnValue = PARENT.TakeWindowEvent()
    CASE EVENT()
    OF EVENT:GainFocus
      if activeProject < 1
          Appframe{PROP:Text} = 'Object Helper: please select active project'
      ELSE
          Appframe{PROP:Text} = 'Object Helper ' & activeProject & ' ' & activeProjectName    
      END
      
      DISPLAY
    END
    RETURN ReturnValue
  END
  ReturnValue = Level:Fatal
  RETURN ReturnValue


FrameExtension.TrayIconMouseLeft2 PROCEDURE


  CODE
  PARENT.TrayIconMouseLeft2
  POST(EVENT:Maximize)

!!! <summary>
!!! Generated from procedure template - Window
!!! Settings
!!! </summary>
BrowseSettings PROCEDURE 

CurrentTab           STRING(80)                            !
BRW1::View:Browse    VIEW(Settings)
                       PROJECT(Set:Nr)
                       PROJECT(Set:Name)
                       PROJECT(Set:Type)
                       PROJECT(Set:Content)
                     END
Queue:Browse:1       QUEUE                            !Queue declaration for browse/combo box using ?Browse:1
Set:Nr                 LIKE(Set:Nr)                   !List box control field - type derived from field
Set:Name               LIKE(Set:Name)                 !List box control field - type derived from field
Set:Type               LIKE(Set:Type)                 !List box control field - type derived from field
Set:Content            LIKE(Set:Content)              !List box control field - type derived from field
Mark                   BYTE                           !Entry's marked status
ViewPosition           STRING(1024)                   !Entry's view position
                     END
BRW1::FormatManager  ListFormatManagerClass,THREAD ! LFM object
BRW1::PopupTextExt   STRING(1024)                 ! Extended popup text
BRW1::PopupChoice    SIGNED                       ! Popup current choice
BRW1::PopupChoiceOn  BYTE(1)                      ! Popup on/off choice
BRW1::PopupChoiceExec BYTE(0)                     ! Popup executed
QuickWindow          WINDOW('Settings'),AT(,,296,198),FONT('Microsoft Sans Serif',8,,FONT:regular,CHARSET:DEFAULT), |
  RESIZE,CENTER,GRAY,IMM,MDI,HLP('BrowseSettings'),SYSTEM
                       LIST,AT(8,30,280,124),USE(?Browse:1),HVSCROLL,FORMAT('64R(2)|M~Nr~C(0)@n-14@80L(2)|M~Na' & |
  'me~L(2)@s60@64R(2)|M~Type~C(0)@n-14@80L(2)|M~Content~L(2)@s254@'),FROM(Queue:Browse:1), |
  IMM,MSG('Settings')
                       BUTTON('&Ansicht'),AT(76,158,50,14),USE(?View:2),LEFT,ICON('WAVIEW.ICO'),FLAT,MSG('nur Ansicht'), |
  TIP('nur Ansicht')
                       BUTTON('&Neu'),AT(130,158,50,14),USE(?Insert:3),LEFT,ICON('WAINSERT.ICO'),FLAT,MSG('Anlegen'), |
  TIP('Satz neu')
                       BUTTON('&Ändern'),AT(184,158,50,14),USE(?Change:3),LEFT,ICON('WACHANGE.ICO'),DEFAULT,FLAT, |
  MSG('Satz ändern'),TIP('Datensatz ändern')
                       BUTTON('&Löschen'),AT(238,158,50,14),USE(?Delete:3),LEFT,ICON('WADELETE.ICO'),FLAT,MSG('Datensatz löschen'), |
  TIP('Datensatz löschen')
                       SHEET,AT(4,4,288,172),USE(?CurrentTab)
                         TAB('&1) NrKey'),USE(?Tab:2)
                         END
                         TAB('&2) NameKey'),USE(?Tab:3)
                         END
                       END
                       BUTTON('&Close'),AT(242,180,50,14),USE(?Close),LEFT,ICON('WACLOSE.ICO'),FLAT,MSG('Fenster schliesen'), |
  TIP('Fenster schliessen')
                     END

BRW1::LastSortOrder       BYTE
BRW1::AutoSizeColumn CLASS(AutoSizeColumnClassType)
               END
ThisWindow           CLASS(WindowManager)
Init                   PROCEDURE(),BYTE,PROC,DERIVED
Kill                   PROCEDURE(),BYTE,PROC,DERIVED
Run                    PROCEDURE(USHORT Number,BYTE Request),BYTE,PROC,DERIVED
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
  GlobalErrors.SetProcedureName('BrowseSettings')
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
  Relate:Settings.Open                            ! File Settings used by this procedure, so make sure it's RelationManager is open
  SELF.FilesOpened = True
  BRW1.Init(?Browse:1,Queue:Browse:1.ViewPosition,BRW1::View:Browse,Queue:Browse:1,Relate:Settings,SELF) ! Initialize the browse manager
  SELF.Open(QuickWindow)                          ! Open window
  !Setting the LineHeight for every control of type LIST/DROP or COMBO in the window using the global setting.
  ?Browse:1{PROP:LineHeight} = 12
  Do DefineListboxStyle
  BRW1.Q &= Queue:Browse:1
  BRW1::Sort1:StepClass.Init(+ScrollSort:AllowAlpha,ScrollBy:Runtime) ! Moveable thumb based upon Set:Name for sort order 1
  BRW1.AddSortOrder(BRW1::Sort1:StepClass,Set:NameKey) ! Add the sort order for Set:NameKey for sort order 1
  BRW1.AddLocator(BRW1::Sort1:Locator)            ! Browse has a locator for sort order 1
  BRW1::Sort1:Locator.Init(,Set:Name,1,BRW1)      ! Initialize the browse locator using  using key: Set:NameKey , Set:Name
  BRW1::Sort0:StepClass.Init(+ScrollSort:AllowAlpha) ! Moveable thumb based upon Set:Nr for sort order 2
  BRW1.AddSortOrder(BRW1::Sort0:StepClass,Set:NrKey) ! Add the sort order for Set:NrKey for sort order 2
  BRW1.AddLocator(BRW1::Sort0:Locator)            ! Browse has a locator for sort order 2
  BRW1::Sort0:Locator.Init(,Set:Nr,1,BRW1)        ! Initialize the browse locator using  using key: Set:NrKey , Set:Nr
  BRW1.AddField(Set:Nr,BRW1.Q.Set:Nr)             ! Field Set:Nr is a hot field or requires assignment from browse
  BRW1.AddField(Set:Name,BRW1.Q.Set:Name)         ! Field Set:Name is a hot field or requires assignment from browse
  BRW1.AddField(Set:Type,BRW1.Q.Set:Type)         ! Field Set:Type is a hot field or requires assignment from browse
  BRW1.AddField(Set:Content,BRW1.Q.Set:Content)   ! Field Set:Content is a hot field or requires assignment from browse
  Resizer.Init(AppStrategy:Surface,Resize:SetMinSize) ! Controls like list boxes will resize, whilst controls like buttons will move
  SELF.AddItem(Resizer)                           ! Add resizer to window manager
  INIMgr.Fetch('BrowseSettings',QuickWindow)      ! Restore window settings from non-volatile store
  Resizer.Resize                                  ! Reset required after window size altered by INI manager
  BRW1.AskProcedure = 1                           ! Will call: UpdateSettings
  BRW1::FormatManager.SaveFormat = True
  ! List Format Manager initialization
  BRW1::FormatManager.Init('ObjectHelper','BrowseSettings',1,?Browse:1,1,BRW1::PopupTextExt,Queue:Browse:1,4,LFM_CFile,LFM_CFile.Record)
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
    Relate:Settings.Close
  END
  ! List Format Manager destructor
  BRW1::FormatManager.Kill() 
  BRW1::AutoSizeColumn.Kill()
  IF SELF.Opened
    INIMgr.Update('BrowseSettings',QuickWindow)            ! Save window data to non-volatile store
  END
  GlobalErrors.SetProcedureName
  RETURN ReturnValue


ThisWindow.Run PROCEDURE(USHORT Number,BYTE Request)

ReturnValue          BYTE,AUTO

  CODE
  ReturnValue = PARENT.Run(Number,Request)
  IF SELF.Request = ViewRecord
    ReturnValue = RequestCancelled                         ! Always return RequestCancelled if the form was opened in ViewRecord mode
  ELSE
    GlobalRequest = Request
    UpdateSettings
    ReturnValue = GlobalResponse
  END
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
  PARENT.Init(ListBox,Posit,V,Q,RM,WM)
  IF WM.Request <> ViewRecord                              ! If called for anything other than ViewMode, make the insert, change & delete controls available
    SELF.InsertControl=?Insert:3
    SELF.ChangeControl=?Change:3
    SELF.DeleteControl=?Delete:3
  END
  SELF.ViewControl = ?View:2                               ! Setup the control used to initiate view only mode


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
!!! Projects
!!! </summary>
BrowseProjects PROCEDURE 

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
QuickWindow          WINDOW('Projects'),AT(,,440,219),FONT('Microsoft Sans Serif',8,,FONT:regular,CHARSET:DEFAULT), |
  NOFRAME,MAXIMIZE,CENTER,GRAY,IMM,MDI,HLP('BrowseProjects'),SYSTEM,WALLPAPER('media\Hint' & |
  'ergrund2018_verlauf_2000.png')
                       LIST,AT(8,30,407,124),USE(?Browse:1),HVSCROLL,FORMAT('33R(2)|M~Nr~C(0)@n_5@80L(2)|M~Nam' & |
  'e~@s60@80L(2)|M~Description~@s254@'),FROM(Queue:Browse:1),IMM,MSG('Projects')
                       BUTTON('&View'),AT(12,158,50,14),USE(?View:2),LEFT,ICON('WAVIEW.ICO'),FLAT,MSG('nur Ansicht'), |
  TIP('nur Ansicht')
                       BUTTON('&Insert'),AT(66,158,50,14),USE(?Insert:3),LEFT,ICON('WAINSERT.ICO'),FLAT,MSG('Anlegen'), |
  TIP('Satz neu')
                       BUTTON('&Change'),AT(120,158,50,14),USE(?Change:3),LEFT,ICON('WACHANGE.ICO'),DEFAULT,FLAT, |
  MSG('Satz ändern'),TIP('Datensatz ändern')
                       BUTTON('&Delete'),AT(174,158,50,14),USE(?Delete:3),LEFT,ICON('WADELETE.ICO'),FLAT,MSG('Datensatz löschen'), |
  TIP('Datensatz löschen')
                       SHEET,AT(4,4,423,172),USE(?CurrentTab)
                         TAB,USE(?Tab:2)
                         END
                         TAB('&2) NameKey'),USE(?Tab:3),HIDE
                         END
                       END
                       BUTTON('&Close'),AT(361,189,51,23),USE(?Close),LEFT,ICON(ICON:Hand),FLAT,MSG('Fenster schliesen'), |
  TIP('Fenster schliessen')
                       BUTTON('set highlighted project active'),AT(12,189,104),USE(?BUTTONProjectactive),LEFT,ICON(ICON:Tick), |
  TIP('make this Project the active one')
                       BUTTON('Browse Project-Files'),AT(121,189,,23),USE(?BUTTONFiles)
                     END

BRW1::LastSortOrder       BYTE
BRW1::AutoSizeColumn CLASS(AutoSizeColumnClassType)
               END
ThisWindow           CLASS(WindowManager)
Init                   PROCEDURE(),BYTE,PROC,DERIVED
Kill                   PROCEDURE(),BYTE,PROC,DERIVED
Run                    PROCEDURE(USHORT Number,BYTE Request),BYTE,PROC,DERIVED
TakeAccepted           PROCEDURE(),BYTE,PROC,DERIVED
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
  GlobalErrors.SetProcedureName('BrowseProjects')
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
  Relate:Settings.Open                            ! File Settings used by this procedure, so make sure it's RelationManager is open
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
  INIMgr.Fetch('BrowseProjects',QuickWindow)      ! Restore window settings from non-volatile store
  Resizer.Resize                                  ! Reset required after window size altered by INI manager
  BRW1.AskProcedure = 1                           ! Will call: UpdateProjects
  BRW1::FormatManager.SaveFormat = True
  ! List Format Manager initialization
  BRW1::FormatManager.Init('ObjectHelper','BrowseProjects',1,?Browse:1,1,BRW1::PopupTextExt,Queue:Browse:1,3,LFM_CFile,LFM_CFile.Record)
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
    Relate:Settings.Close
  END
  ! List Format Manager destructor
  BRW1::FormatManager.Kill() 
  BRW1::AutoSizeColumn.Kill()
  IF SELF.Opened
    INIMgr.Update('BrowseProjects',QuickWindow)            ! Save window data to non-volatile store
  END
  GlobalErrors.SetProcedureName
  RETURN ReturnValue


ThisWindow.Run PROCEDURE(USHORT Number,BYTE Request)

ReturnValue          BYTE,AUTO

  CODE
  ReturnValue = PARENT.Run(Number,Request)
  IF SELF.Request = ViewRecord
    ReturnValue = RequestCancelled                         ! Always return RequestCancelled if the form was opened in ViewRecord mode
  ELSE
    GlobalRequest = Request
    UpdateProjects
    ReturnValue = GlobalResponse
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
    CASE ACCEPTED()
    OF ?BUTTONFiles
      activeProject = Queue:Browse:1.Pro:Nr
      activeProjectName = Queue:Browse:1.Pro:Name
      Set:Nr = 1
      get(settings,Set:NrKey)
      if ~errorcode() 
          Set:Content = activeProject
          put(Settings)
      .
    END
  ReturnValue = PARENT.TakeAccepted()
    CASE ACCEPTED()
    OF ?BUTTONProjectactive
      ThisWindow.Update()
      activeProject = Queue:Browse:1.Pro:Nr
      activeProjectName = Queue:Browse:1.Pro:Name
      Set:Nr = 1
      get(settings,Set:NrKey)
      if ~errorcode() 
          Set:Content = activeProject
          put(Settings)
      .
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
  PARENT.Init(ListBox,Posit,V,Q,RM,WM)
  IF WM.Request <> ViewRecord                              ! If called for anything other than ViewMode, make the insert, change & delete controls available
    SELF.InsertControl=?Insert:3
    SELF.ChangeControl=?Change:3
    SELF.DeleteControl=?Delete:3
  END
  SELF.ViewControl = ?View:2                               ! Setup the control used to initiate view only mode


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
BrowseFiles PROCEDURE 

autofill_in_progress BYTE                                  !
suchlen              LONG                                  !
suchfeld             CSTRING(21)                           !
CurrentTab           STRING(80)                            !
messagefield         STRING(255)                           !
BRW1::View:Browse    VIEW(Files)
                       PROJECT(Files:Nr)
                       PROJECT(Files:Filename)
                       PROJECT(Files:Pathpt2)
                       PROJECT(Files:Pathnum)
                       PROJECT(Files:ProNr)
                       JOIN(Pat:NrKey,Files:Pathnum)
                         PROJECT(Pat:Nr)
                       END
                     END
Queue:Browse:1       QUEUE                            !Queue declaration for browse/combo box using ?Browse:1
Files:Nr               LIKE(Files:Nr)                 !List box control field - type derived from field
Files:Filename         LIKE(Files:Filename)           !List box control field - type derived from field
Files:Pathpt2          LIKE(Files:Pathpt2)            !List box control field - type derived from field
Files:Pathnum          LIKE(Files:Pathnum)            !List box control field - type derived from field
suchfeld               LIKE(suchfeld)                 !Browse hot field - type derived from local data
suchlen                LIKE(suchlen)                  !Browse hot field - type derived from local data
Files:ProNr            LIKE(Files:ProNr)              !Browse key field - type derived from field
Pat:Nr                 LIKE(Pat:Nr)                   !Related join file key field - type derived from field
Mark                   BYTE                           !Entry's marked status
ViewPosition           STRING(1024)                   !Entry's view position
                     END
BRW1::FormatManager  ListFormatManagerClass,THREAD ! LFM object
BRW1::PopupTextExt   STRING(1024)                 ! Extended popup text
BRW1::PopupChoice    SIGNED                       ! Popup current choice
BRW1::PopupChoiceOn  BYTE(1)                      ! Popup on/off choice
BRW1::PopupChoiceExec BYTE(0)                     ! Popup executed
QuickWindow          WINDOW('Files of this project'),AT(,,580,303),FONT('Microsoft Sans Serif',8,,FONT:regular, |
  CHARSET:DEFAULT),RESIZE,MAXIMIZE,CENTER,COLOR(00D3D3D3h),GRAY,IMM,MDI,HLP('BrowseFiles'), |
  SYSTEM
                       LIST,AT(8,45,549,229),USE(?Browse:1),HVSCROLL,ALRT(MouseLeft2),FORMAT('22R(2)|M~Nr~C(0)' & |
  '@n_6@E(00A9A9A9H,,,)116R(2)|M~Filename~C(0)@s255@385L(2)|M~Path~@s254@2L(2)|M~Pathnu' & |
  'm~L(1)@n_4@E(00A9A9A9H,,,)'),FROM(Queue:Browse:1),IMM,MSG('Files')
                       BUTTON('&View Record'),AT(203,286,50,14),USE(?View:2),LEFT,ICON('WAVIEW.ICO'),FLAT,MSG('nur Ansicht'), |
  TIP('nur Ansicht')
                       BUTTON('&New'),AT(277,286,50,14),USE(?Insert:3),LEFT,ICON('WAINSERT.ICO'),FLAT,MSG('Anlegen'), |
  TIP('Satz neu')
                       BUTTON('&Change'),AT(277,286,50,14),USE(?Change:3),LEFT,ICON('WACHANGE.ICO'),DEFAULT,DISABLE, |
  FLAT,HIDE,MSG('Satz ändern'),TIP('Datensatz ändern')
                       BUTTON('&Delete'),AT(331,286,50,14),USE(?Delete:3),LEFT,ICON('WADELETE.ICO'),FLAT,MSG('Datensatz löschen'), |
  TIP('Datensatz löschen')
                       SHEET,AT(4,4,563,280),USE(?CurrentTab)
                         TAB('&1) NrKey'),USE(?Tab:2)
                         END
                         TAB('&2) NameKey'),USE(?Tab:3)
                         END
                       END
                       BUTTON('&Close'),AT(528,286,50,14),USE(?Close),LEFT,ICON('WACLOSE.ICO'),FLAT,MSG('Fenster schliesen'), |
  TIP('Fenster schliessen')
                       BUTTON('autofill (scan the projects paths an read files)'),AT(169,4,223),USE(?BUTTONautofill), |
  COLOR(00228B22h)
                       ENTRY(@s160),AT(8,30,549,10),USE(messagefield)
                       BUTTON('Open File'),AT(24,286,88,14),USE(?BUTTONOpenFile),LEFT,ICON(ICON:Child)
                       ENTRY(@s20),AT(470,4,84),USE(suchfeld),COLOR(00AAE8EEh)
                       BUTTON('X'),AT(557,2,10),USE(?BUTTON_X),FONT(,,,FONT:bold),FLAT,TRN
                     END

BRW1::LastSortOrder       BYTE
BRW1::SortHeader  CLASS(SortHeaderClassType) !Declare SortHeader Class
QueueResorted          PROCEDURE(STRING pString),VIRTUAL
                  END
BRW1::AutoSizeColumn CLASS(AutoSizeColumnClassType)
               END
ThisWindow           CLASS(WindowManager)
Init                   PROCEDURE(),BYTE,PROC,DERIVED
Kill                   PROCEDURE(),BYTE,PROC,DERIVED
Run                    PROCEDURE(USHORT Number,BYTE Request),BYTE,PROC,DERIVED
SetAlerts              PROCEDURE(),DERIVED
TakeAccepted           PROCEDURE(),BYTE,PROC,DERIVED
TakeEvent              PROCEDURE(),BYTE,PROC,DERIVED
TakeFieldEvent         PROCEDURE(),BYTE,PROC,DERIVED
TakeWindowEvent        PROCEDURE(),BYTE,PROC,DERIVED
                     END

Toolbar              ToolbarClass
BRW1                 CLASS(BrowseClass)                    ! Browse using ?Browse:1
Q                      &Queue:Browse:1                !Reference to browse queue
Init                   PROCEDURE(SIGNED ListBox,*STRING Posit,VIEW V,QUEUE Q,RelationManager RM,WindowManager WM)
SetAlerts              PROCEDURE(),DERIVED
SetSort                PROCEDURE(BYTE NewOrder,BYTE Force),BYTE,PROC,DERIVED
TakeNewSelection       PROCEDURE(),DERIVED
                     END

BRW1::Sort0:Locator  StepLocatorClass                      ! Default Locator
BRW1::Sort0:StepClass StepLongClass                        ! Default Step Manager
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
  GlobalErrors.SetProcedureName('BrowseFiles')
  SELF.Request = GlobalRequest                    ! Store the incoming request
  ReturnValue = PARENT.Init()
  IF ReturnValue THEN RETURN ReturnValue.
  SELF.FirstField = ?Browse:1
  SELF.VCRRequest &= VCRRequest
  SELF.Errors &= GlobalErrors                     ! Set this windows ErrorManager to the global ErrorManager
  BIND('suchlen',suchlen)                         ! Added by: BrowseBox(ABC)
  BIND('suchfeld',suchfeld)                       ! Added by: BrowseBox(ABC)
  SELF.AddItem(Toolbar)
  CLEAR(GlobalRequest)                            ! Clear GlobalRequest after storing locally
  CLEAR(GlobalResponse)
  IF SELF.Request = SelectRecord
     SELF.AddItem(?Close,RequestCancelled)        ! Add the close control to the window manger
  ELSE
     SELF.AddItem(?Close,RequestCompleted)        ! Add the close control to the window manger
  END
  Relate:Files.SetOpenRelated()
  Relate:Files.Open                               ! File Files used by this procedure, so make sure it's RelationManager is open
  Access:Paths.UseFile                            ! File referenced in 'Other Files' so need to inform it's FileManager
  Access:Projects.UseFile                         ! File referenced in 'Other Files' so need to inform it's FileManager
  SELF.FilesOpened = True
  BRW1.Init(?Browse:1,Queue:Browse:1.ViewPosition,BRW1::View:Browse,Queue:Browse:1,Relate:Files,SELF) ! Initialize the browse manager
  BRW1.SetUsePopup(False)
  SELF.Open(QuickWindow)                          ! Open window
  !Setting the LineHeight for every control of type LIST/DROP or COMBO in the window using the global setting.
  ?Browse:1{PROP:LineHeight} = 12
  Do DefineListboxStyle
  BRW1.Q &= Queue:Browse:1
  BRW1::Sort0:StepClass.Init(+ScrollSort:AllowAlpha) ! Moveable thumb based upon Files:ProNr for sort order 1
  BRW1.AddSortOrder(BRW1::Sort0:StepClass,Files:ProNrKey) ! Add the sort order for Files:ProNrKey for sort order 1
  BRW1.AddLocator(BRW1::Sort0:Locator)            ! Browse has a locator for sort order 1
  BRW1::Sort0:Locator.Init(,Files:ProNr,1,BRW1)   ! Initialize the browse locator using  using key: Files:ProNrKey , Files:ProNr
  BRW1.SetFilter('(suchlen << 1 OR instring(suchfeld,Files:Filename,1,1))') ! Apply filter expression to browse
  BRW1.AddField(Files:Nr,BRW1.Q.Files:Nr)         ! Field Files:Nr is a hot field or requires assignment from browse
  BRW1.AddField(Files:Filename,BRW1.Q.Files:Filename) ! Field Files:Filename is a hot field or requires assignment from browse
  BRW1.AddField(Files:Pathpt2,BRW1.Q.Files:Pathpt2) ! Field Files:Pathpt2 is a hot field or requires assignment from browse
  BRW1.AddField(Files:Pathnum,BRW1.Q.Files:Pathnum) ! Field Files:Pathnum is a hot field or requires assignment from browse
  BRW1.AddField(suchfeld,BRW1.Q.suchfeld)         ! Field suchfeld is a hot field or requires assignment from browse
  BRW1.AddField(suchlen,BRW1.Q.suchlen)           ! Field suchlen is a hot field or requires assignment from browse
  BRW1.AddField(Files:ProNr,BRW1.Q.Files:ProNr)   ! Field Files:ProNr is a hot field or requires assignment from browse
  BRW1.AddField(Pat:Nr,BRW1.Q.Pat:Nr)             ! Field Pat:Nr is a hot field or requires assignment from browse
  Resizer.Init(AppStrategy:Surface,Resize:SetMinSize) ! Controls like list boxes will resize, whilst controls like buttons will move
  SELF.AddItem(Resizer)                           ! Add resizer to window manager
  INIMgr.Fetch('BrowseFiles',QuickWindow)         ! Restore window settings from non-volatile store
  Resizer.Resize                                  ! Reset required after window size altered by INI manager
  BRW1.AskProcedure = 1                           ! Will call: UpdateFiles
  BRW1::FormatManager.SaveFormat = True
  ! List Format Manager initialization
  BRW1::FormatManager.Init('ObjectHelper','BrowseFiles',1,?Browse:1,1,BRW1::PopupTextExt,Queue:Browse:1,4,LFM_CFile,LFM_CFile.Record)
  BRW1::FormatManager.BindInterface(,,,'.\ObjectHelper.INI')
  SELF.SetAlerts()
  BRW1::AutoSizeColumn.Init()
  BRW1::AutoSizeColumn.AddListBox(?Browse:1,Queue:Browse:1)
  !Initialize the Sort Header using the Browse Queue and Browse Control
  BRW1::SortHeader.Init(Queue:Browse:1,?Browse:1,'','',BRW1::View:Browse)
  BRW1::SortHeader.UseSortColors = False
  RETURN ReturnValue


ThisWindow.Kill PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  ReturnValue = PARENT.Kill()
  IF ReturnValue THEN RETURN ReturnValue.
  IF SELF.FilesOpened
    Relate:Files.Close
  !Kill the Sort Header
  BRW1::SortHeader.Kill()
  END
  ! List Format Manager destructor
  BRW1::FormatManager.Kill() 
  BRW1::AutoSizeColumn.Kill()
  IF SELF.Opened
    INIMgr.Update('BrowseFiles',QuickWindow)               ! Save window data to non-volatile store
  END
  GlobalErrors.SetProcedureName
  RETURN ReturnValue


ThisWindow.Run PROCEDURE(USHORT Number,BYTE Request)

ReturnValue          BYTE,AUTO

  CODE
  ReturnValue = PARENT.Run(Number,Request)
  IF SELF.Request = ViewRecord
    ReturnValue = RequestCancelled                         ! Always return RequestCancelled if the form was opened in ViewRecord mode
  ELSE
    GlobalRequest = Request
    UpdateFiles
    ReturnValue = GlobalResponse
  END
  RETURN ReturnValue


ThisWindow.SetAlerts PROCEDURE

  CODE
  PARENT.SetAlerts
  !Initialize the Sort Header using the Browse Queue and Browse Control
  BRW1::SortHeader.SetAlerts()


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
    OF ?BUTTONautofill
      ThisWindow.Update()
      !Scan paths for appropriate files
      
      if autofill_in_progress = true
          CYCLE
      ELSE
          autofill_in_progress = true
      END
      
      
      Files:ProNr = activeProject
      set(Files:ProNrKey,Files:ProNrKey)
      next(files)
      if ~ERRORCODE()
          case message('clear entries for this project in table?','clean former file entries?',ICON:Question,'Yes (recommended)|No, just add|Cancel')
          of 1
              ?BUTTONautofill{PROP:Background} = COLOR:Aqua
              SETCURSOR(CURSOR:Wait)
              messagefield= 'cleaning table...'
              display()
      
              Files:ProNr = activeProject
              set(Files:ProNrKey,Files:ProNrKey)
              LOOP
                  next(files)
                  if ERRORCODE() then break.
                  delete(files)
              END
              SETCURSOR(CURSOR:Arrow)
          of 2    !do nothing
          of 3
              CYCLE
          END
      
      END
      
      counter# = 0
      
      Pat:ProNr = activeProject
      Pat:LookupPath = ''
      
      set(Pat:ProNrKey,Pat:ProNrKey)
      LOOP
          next(Paths)
          if ERRORCODE() or Pat:ProNr <> activeProject then BREAK.
          counter#+= 1
          
          messagefield = 'scanning ' & Pat:LookupPath
          ?BUTTONautofill{PROP:Background} = COLOR:Blue
          display()
          
          result# = Scandir(Pat:LookupPath,Pat:ProNr)
          
      END
      
      autofill_in_progress = FALSE
      ?BUTTONautofill{PROP:Background} = COLOR:Lime
      
      beep(BEEP:Systemdefault)
      BRW1.ResetFromFile
      
      messagefield =  result# & ' scanned '
      display()
      !
      !  ThisWindow.Reset
        
    OF ?BUTTONOpenFile
      ThisWindow.Update()
      run('"' & clip(Pat:LookupPath) & ' ' & clip(Queue:Browse:1.Files:Pathpt2) & '' & clip(Queue:Browse:1.Files:Filename) & '"')
      !stop(clip(Pat:LookupPath) & ' ' & clip(Queue:Browse:1.Files:Pathpt2) & '' & clip(Queue:Browse:1.Files:Filename))
      
      
      
      !'' & Queue:Browse:1.Files:Pathnum &
    OF ?suchfeld
      suchlen = len(clip(suchfeld))
      
      
      beep(BEEP:Systemdefault)
      
      BRW1.ApplyFilter
      BRW1.ResetFromBuffer
      
      if suchlen THEN messagefield =  'Filter gesetzt ' else messagefield =  '. '.
      display()
    OF ?BUTTON_X
      ThisWindow.Update()
      suchlen = 0
      suchfeld = ''
      
      BRW1.ApplyFilter
      BRW1.ResetFromBuffer
      
      messagefield =  '.'
      display()
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
  IF BRW1::SortHeader.TakeEvents()
     RETURN Level:Notify
  END
  IF BRW1::AutoSizeColumn.TakeEvents()
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
  CASE FIELD()
  OF ?Browse:1
    CASE EVENT()
    OF EVENT:AlertKey
      IF KEYCODE() = MouseLeft2
          thechoice# = CHOICE(?Browse:1)  ! Get current selection in list box
      
          GET(Queue:Browse:1, thechoice#)
          
          Pat:Nr = Queue:Browse:1.Files:Pathnum
          get(Paths,Pat:NrKey)
          if ~ERRORCODE()
              run('"' & clip(Pat:LookupPath) & ' ' & clip(Queue:Browse:1.Files:Pathpt2) & '' & clip(Queue:Browse:1.Files:Filename) & '"') 
          ELSE
              message('Path not available')
          END 
              
      END
      return Level:Cancel
      
    END
  END
  ReturnValue = PARENT.TakeFieldEvent()
  CASE FIELD()
  OF ?Browse:1
    event
    CASE EVENT()
    OF EVENT:AlertKey
      !
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


BRW1.Init PROCEDURE(SIGNED ListBox,*STRING Posit,VIEW V,QUEUE Q,RelationManager RM,WindowManager WM)

  CODE
  PARENT.Init(ListBox,Posit,V,Q,RM,WM)
  IF WM.Request <> ViewRecord                              ! If called for anything other than ViewMode, make the insert, change & delete controls available
    SELF.InsertControl=?Insert:3
    SELF.ChangeControl=?Change:3
    SELF.DeleteControl=?Delete:3
  END
  SELF.ViewControl = ?View:2                               ! Setup the control used to initiate view only mode


BRW1.SetAlerts PROCEDURE

  CODE
  SELF.EditViaPopup = False
  PARENT.SetAlerts


BRW1.SetSort PROCEDURE(BYTE NewOrder,BYTE Force)

ReturnValue          BYTE,AUTO

  CODE
  ReturnValue = PARENT.SetSort(NewOrder,Force)
  IF BRW1::LastSortOrder<>NewOrder THEN
     BRW1::SortHeader.ClearSort()
  END
  IF BRW1::LastSortOrder <> NewOrder THEN
     BRW1::FormatManager.SetCurrentFormat(CHOOSE(NewOrder>0,2,NewOrder+2),'SortOrder'&CHOOSE(NewOrder>0,1,NewOrder+1))
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
     BRW1::SortHeader.RestoreHeaderText()
     BRW1.RestoreSort()
     IF BRW1::FormatManager.DispatchChoice(BRW1::PopupChoice)
        BRW1::SortHeader.ResetSort()
     ELSE
        BRW1::SortHeader.SortQueue()
     END
  END


Resizer.Init PROCEDURE(BYTE AppStrategy=AppStrategy:Resize,BYTE SetWindowMinSize=False,BYTE SetWindowMaxSize=False)


  CODE
  PARENT.Init(AppStrategy,SetWindowMinSize,SetWindowMaxSize)
  SELF.SetParentDefaults()                                 ! Calculate default control parent-child relationships based upon their positions on the window

BRW1::SortHeader.QueueResorted       PROCEDURE(STRING pString)
  CODE
    IF pString = ''
       BRW1.RestoreSort()
       BRW1.ResetSort(True)
    ELSE
       BRW1.ReplaceSort(pString,BRW1::Sort0:Locator)
       BRW1.SetLocatorFromSort()
    END
