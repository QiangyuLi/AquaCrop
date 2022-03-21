unit interface_simul;

interface

uses Global, interface_global, TempProcessing, interface_tempprocessing;

type
    rep_WhichTheta = (AtSAT,AtFC,AtWP,AtAct);

function GetCDCadjustedNoStressNew(
            constref CCx, CDC, CCxAdjusted): double;
     external 'aquacrop' name '__ac_simul_MOD_getcdcadjustednostressnew';

procedure AdjustpLeafToETo(
            constref EToMean : double;
            VAR pLeafULAct : double ;
            VAR pLeafLLAct : double);
     external 'aquacrop' name '__ac_simul_MOD_adjustpleaftoeto';


procedure DeterminePotentialBiomass(
            constref VirtualTimeCC : integer;
            constref cumGDDadjCC : double;
            constref CO2i : double;
            constref GDDayi : double;
            VAR CCxWitheredTpotNoS : double;
            VAR BiomassUnlim : double);
     external 'aquacrop' name '__ac_simul_MOD_determinepotentialbiomass';


procedure AdjustpSenescenceToETo(
           constref EToMean : double;
           constref TimeSenescence : double;
           constref WithBeta : BOOLEAN;
           VAR pSenAct : double);
    external 'aquacrop' name '__ac_interface_simul_MOD_adjustpsenescencetoeto_wrap';



//-----------------------------------------------------------------------------
// BUDGET_module
//-----------------------------------------------------------------------------


function calculate_delta_theta(
             constref theta, thetaAdjFC : double;
             constref NrLayer : integer): double;
     external 'aquacrop' name '__ac_simul_MOD_calculate_delta_theta';

function calculate_theta(
             constref delta_theta, thetaAdjFC : double;
             constref NrLayer : integer): double;
     external 'aquacrop' name '__ac_simul_MOD_calculate_theta';

procedure calculate_drainage();
     external 'aquacrop' name '__ac_simul_MOD_calculate_drainage';

procedure calculate_runoff(constref MaxDepth : double );
     external 'aquacrop' name '__ac_simul_MOD_calculate_runoff';

procedure Calculate_irrigation(var SubDrain : double;
                               var TargetTimeVal, TargetDepthVal : integer);
    external 'aquacrop' name '__ac_simul_MOD_calculate_irrigation'; 

procedure CalculateEffectiveRainfall(var SubDrain : double);
    external 'aquacrop' name '__ac_simul_MOD_calculateeffectiverainfall';

procedure calculate_infiltration(
                VAR InfiltratedRain,InfiltratedIrrigation : double;
                VAR InfiltratedStorage, SubDrain : double);
    external 'aquacrop' name '__ac_simul_MOD_calculate_infiltration';

procedure calculate_Extra_runoff(VAR InfiltratedRain, InfiltratedIrrigation: double;
                                 VAR InfiltratedStorage, SubDrain : double);
    external 'aquacrop' name '__ac_simul_MOD_calculate_extra_runoff';

procedure calculate_surfacestorage(VAR InfiltratedRain,InfiltratedIrrigation: double;
                                   VAR InfiltratedStorage,ECinfilt : double;
                                   constref SubDrain : double;
                                   constref dayi : integer);
    external 'aquacrop' name '__ac_simul_MOD_calculate_surfacestorage';

procedure EffectSoilFertilitySalinityStress(
                        VAR StressSFadjNew : Shortint;
                        constref Coeffb0Salt, Coeffb1Salt, Coeffb2Salt : double;
                        constref NrDayGrow : integer;
                        constref StressTotSaltPrev : double;
                        constref VirtualTimeCC : integer);
    external 'aquacrop' name '__ac_simul_MOD_effectsoilfertilitysalinitystress';

procedure CalculateEvaporationSurfaceWater();
    external 'aquacrop' name '__MOD_simul_calculateevaporationsurfacewater';

function WCEvapLayer(constref Zlayer : double;
                     constref AtTheta : rep_WhichTheta) : double;

function __WCEvapLayer(constref Zlayer : double;
                       constref AtTheta : integer) : double;
    external 'aquacrop' name '__MOD_simul_wcevaplayer';

procedure PrepareStage2();
    external 'aquacrop' name '__MOD_simul_preparestage2';

procedure CalculateEvaporationSurfaceWater();
    external 'aquacrop' name '__MOD_simul_calculateevaporationsurfacewater';

procedure PrepareStage1();
    external 'aquacrop' name '__ac_simul_MOD_preparestage1';

//-----------------------------------------------------------------------------
// end BUDGET_module
//-----------------------------------------------------------------------------


implementation

function WCEvapLayer(constref Zlayer : double;
                     constref AtTheta : rep_WhichTheta) : double
var
    int_attheta : integer;
begin
    int_attheta := ord(AtTheta);
    WCEvapLayer := __WCEvapLayer(Zlayer, int_attheta);
end;


initialization


end.

