UNIT UnitDefDialog;


INTERFACE


USES MyTypes,Dialogs;


  const TopDocumentKey = 1;
        EntreeKey = 3;
        BottomDocumentKey = 4;
        HelpAndInsertKey = 5;
        RetourArriereKey = 8;
        TabulationKey = 9;
        LineFeedKey = 10;
        PageUpKey = 11;
        PageDownKey = 12;
        ReturnKey = 13;
        EscapeKey = 27;
        FlecheGaucheKey = 28;
        FlecheDroiteKey = 29;
        FlecheHautKey = 30;
        FlecheBasKey = 31;
        SuppressionKey = 127;

        VirtualUpdateItemInDialog = 1000;

  type
    RadioRec =
        RECORD
          firstbutton : SInt16;
          lastbutton : SInt16;
          selection : SInt16;
        END;
    CheckSet = set of 0..255;
    ChecksRecord =
        RECORD
          firstCheck : SInt16;
          lastCheck : SInt16;
          selections : CheckSet;
        END;
    SetOfItemNumber = set of 0..255;

    BoutonDrawingProc = procedure(boutonRect : rect; rayonCoins : SInt32);

  {
  var EventHandlerPtr:procPtr;
  }

  var EventHandler : ProcedureType;
      EventHandlerEstInitialise : boolean;
      FiltreClassiqueUPP : ModalFilterUPP;
      FiltreClassiqueAlerteUPP : ModalFilterUPP;
      MyFiltreClassiqueUPP : ModalFilterUPP;


IMPLEMENTATION


{BEGIN_USE_CLAUSE}



{END_USE_CLAUSE}










END.
