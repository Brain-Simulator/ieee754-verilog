pipeline_name = 'ieee_adder'
file_input = 'ieee.v'
file_output = 'ieee_adder.v'
clock_name = 'clock_in'
inputs = [
	('bit','add_sub_bit'), 
	('number','inputA'), 
	('number','inputB'), 
	('bit', clock_name)
]
outputs = [('number','outputC')]
v_includes = '`include "src/defines.v"\n'

widths = {
	'bit' : '',
	'number':'`WIDTH_NUMBER',
	'signif':'`WIDTH_SIGNIF',
	'expo'  :'`WIDTH_EXPO',
	's_part':'`WIDTH_SIGNIF_PART',
}

stages = [
	{ #Stage 1
		'components':[
			{'name':'prepare_input',
				'suffix':'A',
				'override_input':{'number':'inputA','add_sub_bit':"1'b0",}},
			{'name':'prepare_input',
				'suffix':'B',
				'override_input':{'number':'inputB','add_sub_bit':'add_sub_bit',}},
			{'name':'compare',},
			{'name':'shift_signif',},
			{'name':'swap_signif',},
			{'name':'bigger_exp'},
			{'name':'opadd'},
			{'name':'opsub'},
			{'name':'final',},
		],
	},
]
