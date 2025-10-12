File {
  Grid = "NCjlFinFET_msh.tdr"
  Plot   = "@tdrdat@"
  Current= "@plot@"
  Output = "@log@"
}

Electrode {
  { Name="gatec"  Voltage=0.0 Workfunction=5.2 }
  { Name="drainc" Voltage=0.0 }
  { Name="sourcec" Voltage=0.0 }
  { Name="bodyc"  Voltage=0.0 }
}

Physics {
  Fermi
  EffectiveIntrinsicDensity( OldSlotboom )
  Mobility( DopingDep ThinLayer(IALmob()) HighFieldSaturation Enormal )
  Mobility( Enormal( IALMob(AutoOrientation) Lombardi_highk )
            HighFieldSaturation( EparallelToInterface ) )
  Recombination( SRH( DopingDep TempDependence ) )
}

# Ferroelectric polarization: Ginzburg–Landau (LK) on the HZO-equivalent oxide
Physics (region = "hfo2") {
  FEPolarization (
  direction="z" alpha=-6.50e8 beta=5.63e9 gamma=1.0e23 rho=2.25e4 g=0
 )
}

# Optional quantum correction on the channel as in your baseline
Physics (Region="Channel") {
  eQuantumPotential
}

Plot {
FEPolarization
  eDensity hDensity
  TotalCurrent/Vector eCurrent/Vector hCurrent/Vector
  eMobility hMobility
  eVelocity hVelocity
  eQuasiFermi hQuasiFermi
  eTemperature Temperature
  ElectricField/Vector Potential SpaceCharge
  Doping DonorConcentration AcceptorConcentration
  SRH Band2BandGeneration
  ImpactIonization eImpactIonization hImpactIonization
  eGradQuasiFermi/Vector hGradQuasiFermi/Vector
  eEparallel hEparallel eENormal hENormal
  BandGap BandGapNarrowing Affinity
  ConductionBand ValenceBand
  eQuantumPotential
  FEPolarization
}

Math {
NumberOfThreads=8
  RelErrControl
  Digits=10
  ErrRef(electron)=1.e10*(default)
  ErrRef(hole)=1.e10
  Iterations=100
  Notdamped=100
  Method=ILS(set=2)
  SubMethod=PardiSo
  ACMethod=Blocked
  ACSubMethod=ILS(set=2)
}

Solve {
Coupled ( Iterations= 100 LineSearchDamping= 1e-8 ){ Poisson }
Coupled ( Iterations= 100 LineSearchDamping= 1e-8 ){ Poisson eQuantumPotential}
Coupled ( Iterations= 100 LineSearchDamping= 1e-8 ){ Poisson electron hole}
Coupled ( Iterations= 100 LineSearchDamping= 1e-8 ){ Poisson FEPolarization}
Coupled ( Iterations= 100 ){ Poisson electron hole FEPolarization eQuantumPotential}

Transient (
    MaxStep=1e-1 InitialStep=1e-2 MinStep=1e-3
    InitialTime=0 FinalTime=1e-4 Increment=1.2
    Goal { name = "gatec" voltage = 0.001 }
  ) { Coupled { Poisson Electron Hole FEPolarization } }

Quasistationary(
InitialStep= 1e-3 Increment= 2.15 Decrement = 1.15
MinStep= 1e-5 MaxStep= 0.05
Goal { Name= "drainc" Voltage= 0.9 }
){ Coupled { Poisson electron hole FEPolarization eQuantumPotential} }


NewCurrentPrefix= "IdVg_"


Quasistationary(
InitialStep= 1e-3 Increment= 2.15 Decrement = 1.15
MinStep= 1e-5 MaxStep= 0.025
Goal { Name= "gatec" Voltage= 1.0 }
){ Coupled { Poisson electron hole FEPolarization eQuantumPotential} }
}
