/* ****************************************************************
*  Author: RSD                                                    *
*  Date: - 06/25/2017                                             *
*  Description: An assortment of procedures for analyzing         *
*               transient simulation data of QDI circuits. See    *
*               the usage example at the end of this file.        *
*               For additional example usage, see                 *
*               analyze_template.ocn in the Ocean/ folder         *
***************************************************************** */

/* ****************************************************************
 * Ensure the time signal crosses val*vdd is > minTime
***************************************************************** */
procedure( getEdgeTime(EdgeOrTime signal minTime val)
    let( (time edgeNo returnVal)
        edgeNo = 1
        while( greaterp( minTime  
                   if( (val >= 0.5) time = cross( signal (VAR("vdd") * val) edgeNo "rising"  nil nil 0.0001)
                                    time = cross( signal (VAR("vdd") * val) edgeNo "falling" nil nil 0.0001)
                   )
            )
            edgeNo++ 
        )
        if( (strcmp( EdgeOrTime "edge") == 0) 
            returnVal = edgeNo
            if( (strcmp( EdgeOrTime "time") == 0)  
                returnVal = time
                returnVal = list(edgeNo time)
            )
        )
    returnVal
    )
)

/* ****************************************************************
 * Measure Forward + Backward Latencies
***************************************************************** */
procedure( getLatencies(tB4Ledge L Le R)
    UpStart = getEdgeTime("time" L  tB4Ledge  0.6667)
    DnStart = getEdgeTime("time" L  tB4Ledge  0.3333)
    FLUend  = getEdgeTime("time" R  UpStart   0.9)

    FLDend  = getEdgeTime("time" R  DnStart   0.3333)
    BLUend  = getEdgeTime("time" Le UpStart   0.3333)
    BLDend  = getEdgeTime("time" Le DnStart   0.6667)

    FLU = (FLUend - UpStart)
    FLD = (FLDend - DnStart)
    BLU = (BLUend - UpStart)
    BLD = (BLDend - DnStart)

    LatList = list(FLU FLD BLU BLD DnStart)
    LatList
)

/* ****************************************************************
 * Average Measured Forward + Backward Latencies
***************************************************************** */
procedure( avgLatencies(L Le R)
    cycleCount = 1
    cycleCush  = 5
    FLUsum = 0
    FLDsum = 0
    BLUsum = 0
    BLDsum = 0
    minTime = VAR("RESET_HOLD")*2e-12
    while( greaterp(VAR("N_TOKENS")-cycleCush   cycleCount)
        LatList = getLatencies(minTime L Le R)
        FLUsum  = nth(0 LatList) + FLUsum 
        FLDsum  = nth(1 LatList) + FLDsum 
        BLUsum  = nth(2 LatList) + BLUsum
        BLDsum  = nth(3 LatList) + BLDsum 
        minTime = nth(4 LatList)
        cycleCount++
    )
    FLU = FLUsum / (cycleCount - 1)
    FLD = FLDsum / (cycleCount - 1)
    BLU = BLUsum / (cycleCount - 1)
    BLD = BLDsum / (cycleCount - 1)
    avgList = list(FLU FLD BLU BLD)
)

/* ****************************************************************
 * Measure Cycle Time + Energy per Cycle
***************************************************************** */
procedure( getEpCTau( R Current edgeNo )
    start   = cross(R (VAR("vdd") * 2/3) edgeNo   "rising" nil nil 0.0001)
    end     = cross(R (VAR("vdd") * 2/3) edgeNo+1 "rising" nil nil 0.0001)
    Tau     = end - start
    EpC     = integ((Current * VAR("vdd")) start end)
    EpC_Tau = list(EpC Tau)
    EpC_Tau
)

/* ****************************************************************
 * Average Cycle Time + Energy per Cycle
***************************************************************** */
procedure( avgTauEpC( L R Current @optional (cycleCushion 5) (numCycles  VAR("N_TOKENS")) (minStartTime 2e-12*VAR("RESET_HOLD")) )
    cycleCount = 1
    sumEpC = 0
    sumTau = 0
    edgeNo =  getEdgeTime("edge" L minStartTime 0.6667)

    while( greaterp(numCycles-cycleCushion   cycleCount)
        ETau = getEpCTau(R Current edgeNo) 
        sumEpC = nth(0 ETau) + sumEpC
        sumTau = nth(1 ETau) + sumTau
        edgeNo++
        cycleCount++
    )
    avgEpC = sumEpC / (cycleCount - 1)
    avgTau = sumTau / (cycleCount - 1)
    avgList = list(avgTau avgEpC)
    avgList
)

/* ****************************************************************
 * Count Transistors in myCell and recursively descend
 * View    = "schematic"
 * Search Pattern = nmos* pmos*
***************************************************************** */
procedure(countFets(myLib myCell @optional (count 0))
    let(( cv lib cell regex_matches countInCell numbr

        (regex_pattern list( "nmos*" "pmos*"))
     )
     cv=dbOpenCellViewByType( myLib myCell "schematic" "" "r" )

    ;; Check each instance
    foreach( inst cv~>instances
        lib=inst~>master~>libName
        cell=inst~>master~>cellName
        regex_matches=nil

        ;; Check cell name matches the regex_pattern
        foreach(pattern regex_pattern
            when(rexMatchp(pattern inst~>cellName) regex_matches=t)
        )

        when(regex_matches count = count + inst~>numInst)

        ;; Descend the schematic of current instance if it exists
        when(member("schematic" ddGetObj(lib cell)~>views~>name)
                numbr = countFets(lib cell count)
                countInCell = numbr-count
                count=count+countInCell*(inst->numInst)
        )
     ) ; end foreach
    dbClose(cv)
    count
    ) ; end let
) ; end procedure


/* ****************************************************************
* Average Leakage
***************************************************************** */
procedure( getLeakage(Current val)
  Leakage = value(Current (val*VAR("RESET_HOLD")*1e-12))
)

/* ****************************************************************
* Get Leakage, Latencies, CycleTime and Energy per Cycle
***************************************************************** */
procedure( getAll(Current L Le R)

    Leakage  = getLeakage(Current 1.9)
    LatList  = avgLatencies(L Le R)
    TauEList = avgTauEpC(L R Current)
    RetList  = list(Leakage*1e9
                    nth(0 LatList)*1e9
                    nth(1 LatList)*1e9
                    nth(2 LatList)*1e9
                    nth(3 LatList)*1e9
                    nth(0 TauEList)*1e9
                    nth(1 TauEList)*1e15
               )

    printf("Leakage               = %g nA\n" nth(0 RetList))
    printf("Forward  Latency Up   = %g ns\n" nth(1 RetList))
    printf("Forward  Latency Down = %g ns\n" nth(2 RetList))
    printf("Backward Latency Up   = %g ns\n" nth(3 RetList))
    printf("Backward Latency Down = %g ns\n" nth(4 RetList))
    printf("Peak Throughput       = %g MHz\n\n" 1e3/nth(5 RetList))
    
    RetList
)

procedure( printHeaders(fname libCellName)
    file = outfile(fname, "w")
    fprintf(file, "%d\n", countFets("Async" libCellName ))
    fprintf(file, "Vdd[mV] Temp[C] Leakage[nA] FwdLatUp[ns] FwdLatDn[ns] BwdLatUp[ns] BwdLatDn[ns] CycTime[ns] EpC[fJ]\n") 
    close(file)
)

procedure( printToFile(fname temperature AllList)
    file = outfile(fname, "a")
    fprintf(file, "%n %s %g %g %g %g %g %g %g\n", \
    round( VAR("vdd")*1e3 ) temperature nth(0 AllList)  nth(1 AllList) nth(2 AllList) nth(3 AllList) nth(4 AllList)  nth(5 AllList) nth(6 AllList) )
    close(file)
)

/* ****************************************************************
 *                          Example Usage                         *
*******************************************************************
*  load("skill/analyzeQDI.il")
*
*  foreach(corner cornerList
*      filename = strcat( "/root/Desktop/" corner "/PCFB_1of4_" corner ".dat" )
*      printHeaders(filename "PCFB_e1of4")
*    
*      j = 0
*      foreach(job jobList
*          openResults( job )
*          selectResult( 'tran )
*
*          valueList = getAll(IT("/BUFF<0>/VDD") VT("/L0<3>") VT("/Le0") VT("/R0<3>"))
*          printToFile(filename nth(j temps) valueList)
*
*          j = j + 1
*      )
*  )
***************************************************************** */

