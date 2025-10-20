// done : deplaced by basicstring.pas

UNIT StringTypes;


INTERFACE


USES MacTypes, MyTypes
     {$ifc defined __GPC__} ,GPCStrings {$endc}
     ;


  type
    SetOfChar = SET OF CHAR;

  type
     String255Ptr =  ^String255;
     String255Hdl =  ^String255Ptr;

  type
     StringProc = procedure(var s : String255; var result : SInt32);


  type
      MessageDisplayerProc = procedure(msg : String255);
      MessageAndNumDisplayerProc = procedure(msg : String255; num : SInt32);




IMPLEMENTATION








END.