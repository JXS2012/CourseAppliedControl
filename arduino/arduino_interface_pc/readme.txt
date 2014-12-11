sin-folder:
	Read motor input/output through serial and further compute the output rotation speed. Use input_voltage and output_speed to identify system. This is a second order system.

pwm-folder:
	Read motor input/output through serial. Use input_voltage and output_position to identify system. This is a third order system. PWM offers better fit from voltage to position. But it cannot work with speed.
