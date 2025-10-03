UNIT UnitLongintScroller;





INTERFACE







 USES UnitDefCassio;



procedure GetNumerosPremiereEtDernierePartiesAffichees(var premierNumero,derniernumero : SInt32);                                                                                   ATTRIBUTE_NAME('GetNumerosPremiereEtDernierePartiesAffichees')
function GetNumeroPremierePartieAffichee : SInt32;                                                                                                                                  ATTRIBUTE_NAME('GetNumeroPremierePartieAffichee')
function GetNumeroDernierePartieAffichee : SInt32;                                                                                                                                  ATTRIBUTE_NAME('GetNumeroDernierePartieAffichee')
procedure SetValeurAscenseurListe(var value : SInt32);                                                                                                                              ATTRIBUTE_NAME('SetValeurAscenseurListe')
procedure InterpolationPremierePartieAffichee(ControlValue : SInt32);                                                                                                               ATTRIBUTE_NAME('InterpolationPremierePartieAffichee')
procedure CalculeControlLongintMaximum(nbreLignesVisiblesDansFenetre : SInt32);                                                                                                     ATTRIBUTE_NAME('CalculeControlLongintMaximum')
procedure SetControlLongintMaximum(maximum : SInt32);                                                                                                                               ATTRIBUTE_NAME('SetControlLongintMaximum')
procedure SetControlLongintMinimum(minimum : SInt32);                                                                                                                               ATTRIBUTE_NAME('SetControlLongintMinimum')
function GetControlLongintMaximum : SInt32;                                                                                                                                         ATTRIBUTE_NAME('GetControlLongintMaximum')
function GetControlLongintMinimum : SInt32;                                                                                                                                         ATTRIBUTE_NAME('GetControlLongintMinimum')
procedure ActivateAscenseurListe;                                                                                                                                                   ATTRIBUTE_NAME('ActivateAscenseurListe')


IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    FixMath
{$IFC NOT(USE_PRELINK)}
    , UnitListe, UnitRapport, UnitServicesDialogs, UnitCarbonisation ;
{$ELSEC}
    ;
    {$I prelink/LongintScroller.lk}
{$ENDC}


{END_USE_CLAUSE}










Const kSeuilInterpolation = 32000;

procedure GetNumerosPremiereEtDernierePartiesAffichees(var premierNumero,derniernumero : SInt32);
begin
  with infosListeParties do
    begin
      premierNumero := longintValue;
      dernierNumero := premierNumero+nbreLignesFntreListe-1;
      if dernierNumero > nbPartiesActives then dernierNumero := nbPartiesActives;
    end;
end;

function GetNumeroPremierePartieAffichee : SInt32;
var premierNumero : SInt32;
begin
  with infosListeParties do
    begin
      premierNumero := longintValue;
      GetNumeroPremierePartieAffichee := premierNumero;
    end;
end;

function GetNumeroDernierePartieAffichee : SInt32;
var premierNumero,dernierNumero : SInt32;
begin
  with infosListeParties do
    begin
      premierNumero := longintValue;
      dernierNumero := premierNumero+nbreLignesFntreListe-1;
      if dernierNumero > nbPartiesActives then dernierNumero := nbPartiesActives;
      GetNumeroDernierePartieAffichee := dernierNumero;
    end;
end;

procedure SetValeurAscenseurListe(var value : SInt32);
var ratio:Fract;
    maximum,minimum : SInt16;
begin
  with infosListeParties do
    begin
      if value < longintMinimum then value := longintMinimum;
      if value > longintMaximum then value := longintMaximum;
      longintValue := value;

      positionPouceAscenseurListe := longintValue;

      if ascenseurListe = NIL
        then
          begin
            AlerteSimple('ascenseurListe = NIL  dans SetValeurAscenseurListe !!!');
          end
        else
          begin
		      if longintMaximum <= longintMinimum
		        then
		          begin
		            SetControlValue(ascenseurListe,1);
		            HiliteControl(ascenseurListe,255);
		          end
		        else
		          begin
		            minimum := GetControlMinimum(ascenseurListe);
		            maximum := GetControlMaximum(ascenseurListe);
		            if maximum <= kSeuilInterpolation
		              then
		                begin
		                  SetControlValue(ascenseurListe,value);
		                  HiliteControl(ascenseurListe,0);
		                end
		              else
		                begin
		                  if longintMaximum-longintMinimum <> 0
		                    then ratio := FracDiv(value-longintMinimum,longintMaximum-longintMinimum)
		                    else
		                      begin
		                        AlerteSimple('longintMaximum-longintMinimum = 0  dans SetValeurAscenseurListe !!!');
		                        ratio := FracDiv(1,1);  {ou n'importe quoi}
		                      end;
		                  SetControlValue(ascenseurListe,FracMul(ratio,maximum-minimum));
		                  HiliteControl(ascenseurListe,0);
		                end;
		          end;
		    end;
    end;
end;

procedure SetControlLongintMaximum(maximum : SInt32);
begin
  with infosListeParties do
    if ascenseurListe = NIL
      then
        AlerteSimple('ascenseurListe = NIL dans SetControlLongintMaximum')
      else
	    begin
	      longintMaximum := maximum;
	      if longintMaximum <= kSeuilInterpolation
	        then SetControlMaximum(ascenseurListe,maximum)
	        else SetControlMaximum(ascenseurListe,kSeuilInterpolation+1);
	    end;
end;

procedure SetControlLongintMinimum(minimum : SInt32);
begin
  infosListeParties.longintMinimum := minimum;
end;

function GetControlLongintMaximum : SInt32;
begin
  GetControlLongintMaximum := infosListeParties.longintMaximum;
end;

function GetControlLongintMinimum : SInt32;
begin
  GetControlLongintMinimum := infosListeParties.longintMinimum;
end;

procedure InterpolationPremierePartieAffichee(ControlValue : SInt32);
var ratio:Fract;
    minimum,maximum : SInt16;
begin
  with infosListeParties do
    if ascenseurListe = NIL
      then
        AlerteSimple('ascenseurListe = NIL dans InterpolationPremierePartieAffichee')
      else
	    begin
	      minimum := GetControlMinimum(ascenseurListe);
	      maximum := GetControlMaximum(ascenseurListe);
	      if maximum <= kSeuilInterpolation
	        then
	          begin
	            longintValue := ControlValue;
	            positionPouceAscenseurListe := ControlValue;
	          end
	        else
	          begin
	            ratio := FracDiv(ControlValue-minimum,maximum-minimum);
	            longintValue := FracMul(ratio,longintMaximum);
	            if longintValue < longintMinimum then longintValue := longintMinimum;
	            if longintValue > longintMaximum then longintValue := longintMaximum;
	            positionPouceAscenseurListe := longintValue;
	          end;
	    end;
end;

procedure CalculeControlLongintMaximum(nbreLignesVisiblesDansFenetre : SInt32);
begin
  with infosListeParties do
    begin
      longintmaximum := nbPartiesActives-nbreLignesVisiblesDansFenetre+1;
      if longintmaximum < 1 then longintmaximum := 1;
      SetControlLongintMaximum(longintmaximum);
    end;
end;


procedure ActivateAscenseurListe;
var theRect : rect;
begin
  with infosListeParties do
    if ascenseurListe = NIL
      then
        AlerteSimple('ascenseurListe = NIL dans ActivateAscenseurListe')
      else
        begin
          MontrerAscenseurListe;
          InvalRect(GetControlBounds(ascenseurListe,theRect)^);
        end;
end;


end.
