  MEMBER('ObjectHelper.clw')

  INCLUDE('ABFILE.INC'),ONCE

  MAP
ObjectHelper_BC0:DctInit    PROCEDURE
ObjectHelper_BC0:DctKill    PROCEDURE
ObjectHelper_BC0:FilesInit  PROCEDURE
  END

Hide:Access:Settings CLASS(FileManager),TYPE               ! FileManager for Settings
Init                   PROCEDURE(),DERIVED
Kill                   PROCEDURE(),DERIVED
UseFile                PROCEDURE(BYTE UseType = UseType:Uses),BYTE,PROC,DERIVED
ValidateFieldServer    PROCEDURE(UNSIGNED Id,BYTE HandleErrors),BYTE,PROC,DERIVED
                     END


Hide:Relate:Settings CLASS(RelationManager),TYPE           ! RelationManager for Settings
Init                   PROCEDURE
Kill                   PROCEDURE(),DERIVED
                     END

Hide:Access:Projects CLASS(FileManager),TYPE               ! FileManager for Projects
Init                   PROCEDURE(),DERIVED
Kill                   PROCEDURE(),DERIVED
UseFile                PROCEDURE(BYTE UseType = UseType:Uses),BYTE,PROC,DERIVED
                     END


Hide:Relate:Projects CLASS(RelationManager),TYPE           ! RelationManager for Projects
Init                   PROCEDURE
DeferedAddRelations    PROCEDURE(),DERIVED
Kill                   PROCEDURE(),DERIVED
                     END

Hide:Access:Files    CLASS(FileManager),TYPE               ! FileManager for Files
Init                   PROCEDURE(),DERIVED
Kill                   PROCEDURE(),DERIVED
UseFile                PROCEDURE(BYTE UseType = UseType:Uses),BYTE,PROC,DERIVED
                     END


Hide:Relate:Files    CLASS(RelationManager),TYPE           ! RelationManager for Files
Init                   PROCEDURE
DeferedAddRelations    PROCEDURE(),DERIVED
Kill                   PROCEDURE(),DERIVED
                     END

Hide:Access:Paths    CLASS(FileManager),TYPE               ! FileManager for Paths
Init                   PROCEDURE(),DERIVED
Kill                   PROCEDURE(),DERIVED
UseFile                PROCEDURE(BYTE UseType = UseType:Uses),BYTE,PROC,DERIVED
                     END


Hide:Relate:Paths    CLASS(RelationManager),TYPE           ! RelationManager for Paths
Init                   PROCEDURE
DeferedAddRelations    PROCEDURE(),DERIVED
Kill                   PROCEDURE(),DERIVED
                     END

Hide:Access:Includes CLASS(FileManager),TYPE               ! FileManager for Includes
Init                   PROCEDURE(),DERIVED
Kill                   PROCEDURE(),DERIVED
UseFile                PROCEDURE(BYTE UseType = UseType:Uses),BYTE,PROC,DERIVED
                     END


Hide:Relate:Includes CLASS(RelationManager),TYPE           ! RelationManager for Includes
Init                   PROCEDURE
Kill                   PROCEDURE(),DERIVED
                     END

Hide:Access:ASCIIFile CLASS(FileManager),TYPE              ! FileManager for ASCIIFile
Init                   PROCEDURE(),DERIVED
Kill                   PROCEDURE(),DERIVED
UseFile                PROCEDURE(BYTE UseType = UseType:Uses),BYTE,PROC,DERIVED
                     END


Hide:Relate:ASCIIFile CLASS(RelationManager),TYPE          ! RelationManager for ASCIIFile
Init                   PROCEDURE
Kill                   PROCEDURE(),DERIVED
                     END


_Hide:Access:Settings &Hide:Access:Settings,AUTO,THREAD
_Hide:Relate:Settings &Hide:Relate:Settings,AUTO,THREAD
_Hide:Access:Projects &Hide:Access:Projects,AUTO,THREAD
_Hide:Relate:Projects &Hide:Relate:Projects,AUTO,THREAD
_Hide:Access:Files   &Hide:Access:Files,AUTO,THREAD
_Hide:Relate:Files   &Hide:Relate:Files,AUTO,THREAD
_Hide:Access:Paths   &Hide:Access:Paths,AUTO,THREAD
_Hide:Relate:Paths   &Hide:Relate:Paths,AUTO,THREAD
_Hide:Access:Includes &Hide:Access:Includes,AUTO,THREAD
_Hide:Relate:Includes &Hide:Relate:Includes,AUTO,THREAD
_Hide:Access:ASCIIFile &Hide:Access:ASCIIFile,AUTO,THREAD
_Hide:Relate:ASCIIFile &Hide:Relate:ASCIIFile,AUTO,THREAD


ObjectHelper_BC0:DctInit PROCEDURE
  CODE
  _Hide:Access:Settings &= NEW(Hide:Access:Settings)
  _Hide:Relate:Settings &= NEW(Hide:Relate:Settings)
  _Hide:Access:Projects &= NEW(Hide:Access:Projects)
  _Hide:Relate:Projects &= NEW(Hide:Relate:Projects)
  _Hide:Access:Files &= NEW(Hide:Access:Files)
  _Hide:Relate:Files &= NEW(Hide:Relate:Files)
  _Hide:Access:Paths &= NEW(Hide:Access:Paths)
  _Hide:Relate:Paths &= NEW(Hide:Relate:Paths)
  _Hide:Access:Includes &= NEW(Hide:Access:Includes)
  _Hide:Relate:Includes &= NEW(Hide:Relate:Includes)
  _Hide:Access:ASCIIFile &= NEW(Hide:Access:ASCIIFile)
  _Hide:Relate:ASCIIFile &= NEW(Hide:Relate:ASCIIFile)
  Relate:Settings &= _Hide:Relate:Settings
  Relate:Projects &= _Hide:Relate:Projects
  Relate:Files &= _Hide:Relate:Files
  Relate:Paths &= _Hide:Relate:Paths
  Relate:Includes &= _Hide:Relate:Includes
  Relate:ASCIIFile &= _Hide:Relate:ASCIIFile


ObjectHelper_BC0:FilesInit PROCEDURE
  CODE
  _Hide:Relate:Settings.Init
  _Hide:Relate:Projects.Init
  _Hide:Relate:Files.Init
  _Hide:Relate:Paths.Init
  _Hide:Relate:Includes.Init
  _Hide:Relate:ASCIIFile.Init


ObjectHelper_BC0:DctKill PROCEDURE
  CODE
  _Hide:Relate:Settings.Kill
  DISPOSE(_Hide:Relate:Settings)
  _Hide:Relate:Projects.Kill
  DISPOSE(_Hide:Relate:Projects)
  _Hide:Relate:Files.Kill
  DISPOSE(_Hide:Relate:Files)
  _Hide:Relate:Paths.Kill
  DISPOSE(_Hide:Relate:Paths)
  _Hide:Relate:Includes.Kill
  DISPOSE(_Hide:Relate:Includes)
  _Hide:Relate:ASCIIFile.Kill
  DISPOSE(_Hide:Relate:ASCIIFile)


Hide:Relate:Settings.Init PROCEDURE
  CODE
  _Hide:Access:Settings.Init
  SELF.Init(Access:Settings,1)


Hide:Access:Settings.Init PROCEDURE

  CODE
  SELF.Initialized = False
  SELF.Buffer &= Set:Record
  SELF.FileNameValue = 'Settings'
  SELF.SetErrors(GlobalErrors)
  SELF.File &= Settings
  PARENT.Init
  Access:Settings &= SELF


Hide:Access:Settings.Kill PROCEDURE

  CODE
  PARENT.Kill
  Access:Settings &= NULL                                  ! File manager has been destroyed to assign null, it is an error to reference this after this point


Hide:Access:Settings.UseFile PROCEDURE(BYTE UseType = UseType:Uses)

ReturnValue          BYTE,AUTO

  CODE
  IF UseType ~= UseType:Initialize
    SELF.UseFile(UseType:Initialize)                       !Recursive call to ensure initialization takes place
  END
  IF UseType = UseType:Initialize AND ~SELF.Initialized
    SELF.InUseFile = True
    SELF.Init(Settings,GlobalErrors)
    SELF.Create = 1
    SELF.LockRecover = 10
    SELF.AddKey(Set:NrKey,'Set:NrKey',1)
    SELF.AddKey(Set:NameKey,'Set:NameKey',0)
  END
                                                           !SELF.InUseFile will be set to False in PARENT
  ReturnValue = PARENT.UseFile(UseType)
  RETURN ReturnValue


Hide:Access:Settings.ValidateFieldServer PROCEDURE(UNSIGNED Id,BYTE HandleErrors)

ReturnValue          BYTE,AUTO

  CODE
  ReturnValue = PARENT.ValidateFieldServer(Id,HandleErrors)
  CASE Id
  OF 3
    GlobalErrors.SetField('Value|String|Bool|Date')
    IF INSTRING(']' & Set:Type & '[', ']1[]2[]3[]4[', 1, 1) = 0
      ReturnValue = Level:Notify
    END
    IF ReturnValue <> Level:Benign
      IF HandleErrors
        ReturnValue = GlobalErrors.ThrowMessage(Msg:FieldNotInList,'''Value'',''String'',''Bool'',''Date''')
      END
    END
  END
  RETURN ReturnValue


Hide:Relate:Settings.Kill PROCEDURE

  CODE
  _Hide:Access:Settings.Kill                               ! Kill the file manager
  PARENT.Kill
  Relate:Settings &= NULL                                  ! Assign NULL to the RelationManager's FileManager reference, it is an error to reference this after this point
  DISPOSE(_Hide:Access:Settings)                           ! destroy the file manager


Hide:Relate:Projects.Init PROCEDURE
  CODE
  _Hide:Access:Projects.Init
  SELF.Init(Access:Projects,1)


Hide:Access:Projects.Init PROCEDURE

  CODE
  SELF.Initialized = False
  SELF.Buffer &= Pro:Record
  SELF.FileNameValue = 'Projects'
  SELF.SetErrors(GlobalErrors)
  SELF.File &= Projects
  PARENT.Init
  Access:Projects &= SELF


Hide:Access:Projects.Kill PROCEDURE

  CODE
  PARENT.Kill
  Access:Projects &= NULL                                  ! File manager has been destroyed to assign null, it is an error to reference this after this point


Hide:Access:Projects.UseFile PROCEDURE(BYTE UseType = UseType:Uses)

ReturnValue          BYTE,AUTO

  CODE
  IF UseType ~= UseType:Initialize
    SELF.UseFile(UseType:Initialize)                       !Recursive call to ensure initialization takes place
  END
  IF UseType = UseType:Initialize AND ~SELF.Initialized
    SELF.InUseFile = True
    SELF.Init(Projects,GlobalErrors)
    SELF.Create = 1
    SELF.LockRecover = 10
    SELF.AddKey(Pro:NrKey,'Pro:NrKey',1)
    SELF.AddKey(Pro:NameKey,'Pro:NameKey',0)
  END
                                                           !SELF.InUseFile will be set to False in PARENT
  ReturnValue = PARENT.UseFile(UseType)
  RETURN ReturnValue


Hide:Relate:Projects.DeferedAddRelations PROCEDURE

  CODE
  DO AddRelations_1
  
  PARENT.DeferedAddRelations

AddRelations_1 ROUTINE
  SELF.AddRelation(Relate:Files,RI:CASCADE,RI:CASCADE,Files:ProNrKey)
  SELF.AddRelationLink(Pro:Nr,Files:ProNr)

  SELF.AddRelation(Relate:Paths,RI:CASCADE,RI:CASCADE,Pat:ProNrKey)
  SELF.AddRelationLink(Pro:Nr,Pat:ProNr)


Hide:Relate:Projects.Kill PROCEDURE

  CODE
  _Hide:Access:Projects.Kill                               ! Kill the file manager
  PARENT.Kill
  Relate:Projects &= NULL                                  ! Assign NULL to the RelationManager's FileManager reference, it is an error to reference this after this point
  DISPOSE(_Hide:Access:Projects)                           ! destroy the file manager


Hide:Relate:Files.Init PROCEDURE
  CODE
  _Hide:Access:Files.Init
  SELF.Init(Access:Files,1)


Hide:Access:Files.Init PROCEDURE

  CODE
  SELF.Initialized = False
  SELF.Buffer &= Files:Record
  SELF.FileNameValue = 'Files'
  SELF.SetErrors(GlobalErrors)
  SELF.File &= Files
  PARENT.Init
  Access:Files &= SELF


Hide:Access:Files.Kill PROCEDURE

  CODE
  PARENT.Kill
  Access:Files &= NULL                                     ! File manager has been destroyed to assign null, it is an error to reference this after this point


Hide:Access:Files.UseFile PROCEDURE(BYTE UseType = UseType:Uses)

ReturnValue          BYTE,AUTO

  CODE
  IF UseType ~= UseType:Initialize
    SELF.UseFile(UseType:Initialize)                       !Recursive call to ensure initialization takes place
  END
  IF UseType = UseType:Initialize AND ~SELF.Initialized
    SELF.InUseFile = True
    SELF.Init(Files,GlobalErrors)
    SELF.Create = 1
    SELF.LockRecover = 10
    SELF.AddKey(Files:NrKey,'Files:NrKey',1)
    SELF.AddKey(Files:ProNrKey,'Files:ProNrKey',0)
    SELF.AddKey(Files:PathnumKey,'Files:PathnumKey',0)
    SELF.AddKey(Files:FilenameKey,'Files:FilenameKey',0)
  END
                                                           !SELF.InUseFile will be set to False in PARENT
  ReturnValue = PARENT.UseFile(UseType)
  RETURN ReturnValue


Hide:Relate:Files.DeferedAddRelations PROCEDURE

  CODE
  DO AddRelations_1
  
  PARENT.DeferedAddRelations

AddRelations_1 ROUTINE
  SELF.AddRelation(Relate:Projects)

  SELF.AddRelation(Relate:Paths)


Hide:Relate:Files.Kill PROCEDURE

  CODE
  _Hide:Access:Files.Kill                                  ! Kill the file manager
  PARENT.Kill
  Relate:Files &= NULL                                     ! Assign NULL to the RelationManager's FileManager reference, it is an error to reference this after this point
  DISPOSE(_Hide:Access:Files)                              ! destroy the file manager


Hide:Relate:Paths.Init PROCEDURE
  CODE
  _Hide:Access:Paths.Init
  SELF.Init(Access:Paths,1)


Hide:Access:Paths.Init PROCEDURE

  CODE
  SELF.Initialized = False
  SELF.Buffer &= Pat:Record
  SELF.FileNameValue = 'Paths'
  SELF.SetErrors(GlobalErrors)
  SELF.File &= Paths
  PARENT.Init
  Access:Paths &= SELF


Hide:Access:Paths.Kill PROCEDURE

  CODE
  PARENT.Kill
  Access:Paths &= NULL                                     ! File manager has been destroyed to assign null, it is an error to reference this after this point


Hide:Access:Paths.UseFile PROCEDURE(BYTE UseType = UseType:Uses)

ReturnValue          BYTE,AUTO

  CODE
  IF UseType ~= UseType:Initialize
    SELF.UseFile(UseType:Initialize)                       !Recursive call to ensure initialization takes place
  END
  IF UseType = UseType:Initialize AND ~SELF.Initialized
    SELF.InUseFile = True
    SELF.Init(Paths,GlobalErrors)
    SELF.Create = 1
    SELF.LockRecover = 10
    SELF.AddKey(Pat:NrKey,'Pat:NrKey',1)
    SELF.AddKey(Pat:NameKey,'ProNr and Path',0)
    SELF.AddKey(Pat:ProNrKey,'Pat:ProNrKey',0)
  END
                                                           !SELF.InUseFile will be set to False in PARENT
  ReturnValue = PARENT.UseFile(UseType)
  RETURN ReturnValue


Hide:Relate:Paths.DeferedAddRelations PROCEDURE

  CODE
  DO AddRelations_1
  
  PARENT.DeferedAddRelations

AddRelations_1 ROUTINE
  SELF.AddRelation(Relate:Projects)

  SELF.AddRelation(Relate:Files,RI:CASCADE,RI:CASCADE,Files:PathnumKey)
  SELF.AddRelationLink(Pat:Nr,Files:Pathnum)


Hide:Relate:Paths.Kill PROCEDURE

  CODE
  _Hide:Access:Paths.Kill                                  ! Kill the file manager
  PARENT.Kill
  Relate:Paths &= NULL                                     ! Assign NULL to the RelationManager's FileManager reference, it is an error to reference this after this point
  DISPOSE(_Hide:Access:Paths)                              ! destroy the file manager


Hide:Relate:Includes.Init PROCEDURE
  CODE
  _Hide:Access:Includes.Init
  SELF.Init(Access:Includes,1)


Hide:Access:Includes.Init PROCEDURE

  CODE
  SELF.Initialized = False
  SELF.Buffer &= Incl:Record
  SELF.FileNameValue = 'Includes'
  SELF.SetErrors(GlobalErrors)
  SELF.File &= Includes
  PARENT.Init
  Access:Includes &= SELF


Hide:Access:Includes.Kill PROCEDURE

  CODE
  PARENT.Kill
  Access:Includes &= NULL                                  ! File manager has been destroyed to assign null, it is an error to reference this after this point


Hide:Access:Includes.UseFile PROCEDURE(BYTE UseType = UseType:Uses)

ReturnValue          BYTE,AUTO

  CODE
  IF UseType ~= UseType:Initialize
    SELF.UseFile(UseType:Initialize)                       !Recursive call to ensure initialization takes place
  END
  IF UseType = UseType:Initialize AND ~SELF.Initialized
    SELF.InUseFile = True
    SELF.Init(Includes,GlobalErrors)
    SELF.Create = 1
    SELF.LockRecover = 10
    SELF.AddKey(Incl:NrKey,'Incl:NrKey',1)
    SELF.AddKey(Incl:FilenameNrKey,'Nr in Files',0)
  END
                                                           !SELF.InUseFile will be set to False in PARENT
  ReturnValue = PARENT.UseFile(UseType)
  RETURN ReturnValue


Hide:Relate:Includes.Kill PROCEDURE

  CODE
  _Hide:Access:Includes.Kill                               ! Kill the file manager
  PARENT.Kill
  Relate:Includes &= NULL                                  ! Assign NULL to the RelationManager's FileManager reference, it is an error to reference this after this point
  DISPOSE(_Hide:Access:Includes)                           ! destroy the file manager


Hide:Relate:ASCIIFile.Init PROCEDURE
  CODE
  _Hide:Access:ASCIIFile.Init
  SELF.Init(Access:ASCIIFile,1)


Hide:Access:ASCIIFile.Init PROCEDURE

  CODE
  SELF.Initialized = False
  SELF.Buffer &= ASC:Record
  SELF.FileNameValue = 'ASCIIFile'
  SELF.SetErrors(GlobalErrors)
  SELF.File &= ASCIIFile
  PARENT.Init
  Access:ASCIIFile &= SELF


Hide:Access:ASCIIFile.Kill PROCEDURE

  CODE
  PARENT.Kill
  Access:ASCIIFile &= NULL                                 ! File manager has been destroyed to assign null, it is an error to reference this after this point


Hide:Access:ASCIIFile.UseFile PROCEDURE(BYTE UseType = UseType:Uses)

ReturnValue          BYTE,AUTO

  CODE
  IF UseType ~= UseType:Initialize
    SELF.UseFile(UseType:Initialize)                       !Recursive call to ensure initialization takes place
  END
  IF UseType = UseType:Initialize AND ~SELF.Initialized
    SELF.InUseFile = True
    SELF.Init(ASCIIFile,GlobalErrors)
    SELF.Create = 0
    SELF.LockRecover = 10
  END
                                                           !SELF.InUseFile will be set to False in PARENT
  ReturnValue = PARENT.UseFile(UseType)
  RETURN ReturnValue


Hide:Relate:ASCIIFile.Kill PROCEDURE

  CODE
  _Hide:Access:ASCIIFile.Kill                              ! Kill the file manager
  PARENT.Kill
  Relate:ASCIIFile &= NULL                                 ! Assign NULL to the RelationManager's FileManager reference, it is an error to reference this after this point
  DISPOSE(_Hide:Access:ASCIIFile)                          ! destroy the file manager

