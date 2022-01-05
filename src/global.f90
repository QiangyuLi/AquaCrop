module ac_global

use ac_kinds, only: dp, &
                    int8, &
                    int16, &
                    int32, &
                    intEnum
implicit none


integer(int16), parameter :: max_SoilLayers = 5
real(dp), parameter :: undef_double = -9.9_dp
    !! value for 'undefined' real(dp) variables
integer(int16), parameter :: undef_int = -9
    !! value for 'undefined' int16 variables

integer(intEnum), parameter :: modeCycle_GDDDays = 0
    !! index of GDDDays in modeCycle enumerated type
integer(intEnum), parameter :: modeCycle_CalendarDays = 1
    !! index of CalendarDays in modeCycle enumerated type

type SoilLayerIndividual
    character(len=25) :: Description
        !! Undocumented
    real(dp) :: Thickness
        !! meter
    real(dp) :: SAT
        !! Vol % at Saturation
    real(dp) :: FC
        !! Vol % at Field Capacity
    real(dp) :: WP
        !! Vol % at Wilting Point
    real(dp) :: tau
        !! drainage factor 0 ... 1
    real(dp) :: InfRate
        !! Infiltration rate at saturation mm/day
    integer(int8) :: Penetrability
        !! root zone expansion rate in percentage
    integer(int8) :: GravelMass
        !! mass percentage of gravel
    real(dp) :: GravelVol
        !! volume percentage of gravel
    real(dp) :: WaterContent
        !! mm
    ! salinity parameters (cells)
    integer(int8) :: Macro
        !! Macropores : from Saturation to Macro [vol%]
    real(dp), dimension(11) :: SaltMobility
        !! Mobility of salt in the various salt cellS
    integer(int8) :: SC
        !! number of Saltcels between 0 and SC/(SC+2)*SAT vol%
    integer(int8) :: SCP1
        !! SC + 1   (1 extra Saltcel between SC/(SC+2)*SAT vol% and SAT)
        !! THis last celL is twice as large as the other cels *)
    real(dp) :: UL
        !! Upper Limit of SC salt cells = SC/(SC+2) * (SAT/100) in m3/m3
    real(dp) :: Dx
        !! Size of SC salt cells [m3/m3] = UL/SC
    ! capilary rise parameters
    integer(int8) :: SoilClass
        !! 1 = sandy, 2 = loamy, 3 = sandy clayey, 4 - silty clayey soils
    real(dp) :: CRa, CRb
        !! coefficients for Capillary Rise
end type SoilLayerIndividual


contains


real(dp) function AquaCropVersion(FullNameXXFile)
    character(len=*), intent(in) :: FullNameXXFile

    integer :: fhandle
    real(dp) :: VersionNr

    open(newunit=fhandle, file=trim(FullNameXXFile), status='old', &
         action='read')

    read(fhandle, *)  ! Description
    read(fhandle, *) VersionNr  ! AquaCrop version

    close(fhandle)

    AquaCropVersion = VersionNr
end function AquaCropVersion


subroutine ZrAdjustedToRestrictiveLayers(ZrIN, TheNrSoilLayers, TheLayer, ZrOUT)
    real(dp), intent(in) :: ZrIN
    integer(int8), intent(in) :: TheNrSoilLayers
    type(SoilLayerIndividual), dimension(max_SoilLayers), intent(in) :: TheLayer
    real(dp), intent(inout) :: ZrOUT

    integer :: Layi
    real(dp) :: Zsoil, ZrAdj, ZrRemain, DeltaZ, ZrTest
    logical :: TheEnd

    ZrOUT = ZrIn

    ! // Adjust ZminYear1 when Zmax <= ZminYear1 since calculation for reduction start at ZminYear1
    ! IF ROUND(ZrIN*1000) <= ROUND(CropZMinY1*1000) THEN
    !     CropZMinY1 := 0.30;
    !     IF ROUND(ZrIN*1000) <= ROUND(CropZMinY1*1000) THEN
    !         CropZMinY1 := ZrIN - 0.05;
    !     end if
    ! end if
    !
    ! // start at CropZMinY1
    ! layi := 1;
    ! Zsoil := TheLayer[layi].Thickness;
    ! WHILE ((ROUND(Zsoil*1000) <= ROUND(CropZMinY1*1000)) AND (layi < TheNrSoilLayers)) DO
    !     layi := layi + 1;
    !     Zsoil := Zsoil + TheLayer[layi].Thickness;
    ! end do
    ! ZrAdj := CropZMinY1;
    ! ZrRemain := ZrIN - CropZMinY1;
    ! DeltaZ := Zsoil - CropZMinY1;   *)

    ! initialize (layer 1)
    layi = 1
    Zsoil = TheLayer(layi)%Thickness
    ZrAdj = 0
    ZrRemain = ZrIN
    DeltaZ = Zsoil
    TheEnd = .false.

    ! check succesive layers
    do while (.not. TheEnd)
        ZrTest = ZrAdj + ZrRemain * (TheLayer(layi)%Penetrability/100._dp)

        if ((layi == TheNrSoilLayers) &
            .or. (TheLayer(layi)%Penetrability == 0) &
            .or. (nint(ZrTest*10000) <= nint(Zsoil*10000))) then
            ! no root expansion in layer
            TheEnd = .true.
            ZrOUT = ZrTest
        else
            ZrAdj = Zsoil
            ZrRemain = ZrRemain - DeltaZ/(TheLayer(layi)%Penetrability/100._dp)
            layi = layi + 1
            Zsoil = Zsoil + TheLayer(layi)%Thickness
            DeltaZ = TheLayer(layi)%Thickness
        end if
    end do
end subroutine ZrAdjustedToRestrictiveLayers


subroutine set_layer_undef(LayerData)
    type(SoilLayerIndividual), intent(inout) :: LayerData

    integer(int16) :: i

    LayerData%Description = ''
    LayerData%Thickness = undef_double
    LayerData%SAT = undef_double
    LayerData%FC = undef_double
    LayerData%WP = undef_double
    LayerData%tau = undef_double
    LayerData%InfRate = undef_double
    LayerData%Penetrability = undef_int
    LayerData%GravelMass = undef_int
    LayerData%GravelVol = undef_int
    LayerData%Macro = undef_int
    LayerData%UL = undef_double
    LayerData%Dx = undef_double
    do i = 1, 11
        LayerData%SaltMobility(i) = undef_double  ! maximum 11 salt cells
    end do
    LayerData%SoilClass = undef_int
    LayerData%CRa = undef_int
    LayerData%CRb = undef_int
    LayerData%WaterContent = undef_double
end subroutine set_layer_undef


real(dp) function TimeRootFunction(t, ShapeFactor, tmax, t0)
    real(dp), intent(in) :: t
    integer(int8), intent(in) :: ShapeFactor
    real(dp), intent(in) :: tmax
    real(dp), intent(in) :: t0

    TimeRootFunction = exp((10._dp / ShapeFactor) * log((t-t0) / (tmax-t0)))
end function TimeRootFunction


real(dp) function TimeToReachZroot(Zi, Zo, Zx, ShapeRootDeepening, Lo, LZxAdj)
    real(dp), intent(in) :: Zi
    real(dp), intent(in) :: Zo
    real(dp), intent(in) :: Zx
    integer(int8), intent(in) :: ShapeRootDeepening
    integer(int16), intent(in) :: Lo
    integer(int16), intent(in) :: LZxAdj

    real(dp) :: ti, T1

    ti = real(undef_int, kind=dp)

    if (nint(Zi*100) >= nint(Zx*100)) then
        ti = real(LZxAdj, kind=dp)
    else
        if (((Zo+0.0001_dp) < Zx) .and. (LZxAdj > Lo/2._dp) .and. (LZxAdj > 0) &
            .and. (ShapeRootDeepening > 0)) then
            T1 = exp((ShapeRootDeepening/10._dp) * log((Zi-Zo) / (Zx-Zo)))
            ti = T1 * (LZxAdj - Lo/2._dp) + Lo/2._dp
        end if
    end if

    TimeToReachZroot = ti
end function TimeToReachZroot


real(dp) function GetWeedRC(TheDay, GDDayi, fCCx, TempWeedRCinput, TempWeedAdj,&
                            TempWeedDeltaRC, L12SF, TempL123, GDDL12SF, &
                            TempGDDL123, TheModeCycle)
    integer(int16), intent(in) :: TheDay
    real(dp), intent(in) :: GDDayi
    real(dp), intent(in) :: fCCx
    integer(int8), intent(in) :: TempWeedRCinput
    integer(int8), intent(in) :: TempWeedAdj
    integer(int16), intent(inout) :: TempWeedDeltaRC
    integer(int16), intent(in) :: L12SF
    integer(int16), intent(in) :: TempL123
    integer(int16), intent(in) :: GDDL12SF
    integer(int16), intent(in) :: TempGDDL123
    integer(intEnum), intent(in) :: TheModeCycle

    real(dp) :: WeedRCDayCalc

    WeedRCDayCalc = TempWeedRCinput

    if ((TempWeedRCinput > 0) .and. (TempWeedDeltaRC /= 0)) then
        ! daily RC when increase/decline of RC in season (i.e. TempWeedDeltaRC <> 0)
        ! adjust the slope of increase/decline of RC in case of self-thinning (i.e. fCCx < 1)
        if ((TempWeedDeltaRC /= 0) .and. (fCCx < 0.999_dp)) then
            ! only when self-thinning and there is increase/decline of RC
            if (fCCx < 0.005_dp) then
                TempWeedDeltaRC = 0
            else
                TempWeedDeltaRC = nint(TempWeedDeltaRC * exp( &
                                       log(fCCx) * (1+TempWeedAdj/100._dp)), &
                                       kind=int16)
            end if
        end if

        ! calculate WeedRCDay by considering (adjusted) decline/increase of RC
        if (TheModeCycle == modeCycle_CalendarDays) then
            if (TheDay > L12SF) then
                if (TheDay >= TempL123) then
                    WeedRCDayCalc = TempWeedRCinput * (1 + &
                                        TempWeedDeltaRC/100._dp)
                else
                    WeedRCDayCalc = TempWeedRCinput * (1 + &
                                        (TempWeedDeltaRC/100._dp) &
                                         * (TheDay-L12SF) / (TempL123-L12SF))
                end if
            end if
        else
            if (GDDayi > GDDL12SF) then
                if (GDDayi > TempGDDL123) then
                    WeedRCDayCalc = TempWeedRCinput * (1 + &
                                        TempWeedDeltaRC/100._dp)
                else
                    WeedRCDayCalc = TempWeedRCinput * (1 + &
                                        (TempWeedDeltaRC/100._dp) &
                                         * (GDDayi-GDDL12SF) &
                                         / (TempGDDL123-GDDL12SF))
                end if
            end if
        end if

        ! fine-tuning for over- or undershooting in case of self-thinning
        if (fCCx < 0.999_dp) then
            ! only for self-thinning
            if ((fCCx < 1) .and. (fCCx > 0) .and. (WeedRCDayCalc > 98)) then
                WeedRCDayCalc = 98._dp
            end if
            if (WeedRCDayCalc < 0) then
                WeedRCDayCalc = 0._dp
            end if
            if (fCCx <= 0) then
                WeedRCDayCalc = 100._dp
            end if
        end if
    end if

    GetWeedRC = WeedRCDayCalc
end function GetWeedRC

real(dp) function MultiplierCCxSelfThinning(Yeari, Yearx, ShapeFactor)
    integer(int32), intent(in) :: Yeari
    integer(int32), intent(in) :: Yearx
    real(dp), intent(in) :: ShapeFactor

    real(dp) :: fCCx, Year0
    
    fCCx = 1
    if ((Yeari >= 2) .and. (Yearx >= 2) .and. (nint(100._dp*ShapeFactor, &
                                                    int32) /= 0)) then
        Year0 = 1._dp + (Yearx-1._dp) * exp(ShapeFactor*log(10._dp))
        if (Yeari >= Year0) then
            fCCx = 0
        else
            fCCx = 0.9_dp + 0.1_dp * (1._dp - exp((1._dp/ShapeFactor) &
                        *log(real((Yeari-1._dp)/(Yearx-1._dp),dp))))
        end if
        if (fCCx < 0) then
            fCCx = 0
        end if
    end if
    MultiplierCCxSelfThinning = fCCx     
end function MultiplierCCxSelfThinning

integer(int32) function DaysToReachCCwithGivenCGC(CCToReach, CCoVal, &
                                                        CCxVal, CGCVal, L0)
    real(dp), intent(inout) :: CCToReach
    real(dp), intent(in) :: CCoVal
    real(dp), intent(in) :: CCxVal
    real(dp), intent(in) :: CGCVal
    integer(int32), intent(in) :: L0

    real(dp) :: L
    if ((CCoVal > CCToReach) .or. (CCoVal >= CCxVal)) then
        L = 0
    else
        if (CCToReach > (0.98_dp*CCxVal)) then
            CCToReach = 0.98_dp*CCxVal
        end if
        if (CCToReach <= CCxVal/2._dp) then
            L = log(CCToReach/CCoVal)/CGCVal
        else
            L = log((0.25_dp*CCxVal*CCxVal/CCoVal)/(CCxVal-CCToReach))/CGCVal
        end if

    end if
    DaysToReachCCwithGivenCGC = L0 + nint(L, int32)
end function DaysToReachCCwithGivenCGC

integer(int32) function LengthCanopyDecline(CCx, CDC)
    real(dp), intent(in) :: CCx
    real(dp), intent(in) :: CDC

    integer(int32) :: ND

    ND = 0
    if (CCx > 0) then
        if (CDC <= epsilon(1._dp)) then
            ND = undef_int
        else
            ND = nint((((CCx+2.29_dp)/(CDC*3.33_dp))*log(1._dp + 1._dp/0.05 &
                     ) + 0.50_dp), int32)  ! + 0.50 to guarantee that CC is zero
        end if

    end if
    LengthCanopyDecline = ND
end function LengthCanopyDecline



end module ac_global
