  MEMBER('ObjectHelper.clw')

  PRAGMA('define(init_priority=>3)')

  MAP
    MODULE('ObjectHelper_BC0.CLW')
ObjectHelper_BC0:DctInit             PROCEDURE
ObjectHelper_BC0:DctKill             PROCEDURE
ObjectHelper_BC0:FilesInit           PROCEDURE
    END
  END

DctInit PROCEDURE
  CODE
  ObjectHelper_BC0:DctInit
  ObjectHelper_BC0:FilesInit


DctKill PROCEDURE
  CODE
  ObjectHelper_BC0:DctKill

