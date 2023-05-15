within PowerGrids.Electrical.Buses;
model BusFault
  extends Icons.Bus;
  extends Electrical.BaseClasses.OnePortAC;

  type FaultState = enumeration(Normal, Faulty, Clearing);

  parameter Types.Resistance R = 0 "Series resistance to ground during fault" annotation(Dialog(group="Fault data"));
  parameter Types.Reactance X = 0 "Series reactance to ground during fault" annotation(Dialog(group="Fault data"));
  parameter SI.Time startTime "Start time of the fault" annotation(Dialog(group="Fault data"));
  parameter SI.Time stopTime "End time of the fault" annotation(Dialog(group="Fault data"));

  Types.ComplexVoltage v(re(nominal = port.VBase), im(nominal = port.VBase)) = port.v "Port voltage, phase-to-ground";
  Types.ComplexCurrent i(re(nominal = port.IBase), im(nominal = port.IBase)) = port.i "Port current";

  FaultState state(start = FaultState.Normal, fixed = true) "Fault state";
  discrete Types.ComplexVoltage vClearing(re(start = 0, fixed = true), im(start = 0, fixed = true)) "Voltage to apply when clearing fault";
  Types.ComplexAdmittance Y(re(start = 0, fixed = true), im(start = 0, fixed = true)) "Shunt admittance";
  Types.ComplexVoltage v0(re(start = 0, fixed = true), im(start = 0, fixed = true)) "Voltage on the other side of the fault admittance";

// State machine for fault state
algorithm
   when time >= startTime then
     state := FaultState.Faulty;
     // vClearing = pre(v);    // Voltage before the fault is set aside for clearing phase
     vClearing.re := pre(v.re);
     vClearing.im := pre(v.im);
   end when;

   when time >= stopTime then
     state := FaultState.Clearing;
   end when;

   when pre(state) == FaultState.Clearing then
     state := FaultState.Normal;
   end when;

equation
   i = Y*(v - v0);
   when pre(state) == FaultState.Faulty then
   end when;

   if state == FaultState.Normal then
     // Y = Complex(0);
     Y.re = 0;
     Y.im = 0;
   else
     // Y = 1/Complex(R, X);
     Y.re = R/(R^2+X^2);
     Y.im = -X/(R^2+X^2);
   end if;

   if state == FaultState.Clearing then
     // v0 = vClearing;
     v0.re = vClearing.re;
     v0.im = vClearing.im;
   else
     // v0 = Complex(0);
     v0.re = 0;
     v0.im = 0;
   end if;
annotation (
    Icon(coordinateSystem(grid = {0.1, 0.1}), graphics={  Line(origin = {-64.98, -38}, points = {{-3.01972, 29.9973}, {18.9803, 9.99729}, {-19.0197, -12.0027}, {2.98028, -30.0027}}, thickness = 1, arrow = {Arrow.None, Arrow.Filled}, arrowSize = 6)}));
end BusFault;
