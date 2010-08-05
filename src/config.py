pipeline_name = 'ieee_adder'
file_input = 'ieee.v'
file_output = 'ieee_adder.v'
clock_name = 'clock_in'
inputs = [('bit','add_sub_bit'), ('number','inputA'), ('number','inputB'), ('bit', clock_name)]
outputs = [('number','outputC')]
v_includes = '`include "src/defines.v"\n'

stages = [
	{ #Stage 0
		'components':[
			{'name':'__input_stage__'},
		],
	},
	{ #Stage 1
		'components':[
			{'name':'prepare_input','suffix':'A',
				'override_input':{'add_sub_bit':'add_sub_bit','number':'inputA'}},
			{'name':'prepare_input','suffix':'B',
				'override_input':{'add_sub_bit':'add_sub_bit','number':'inputB'}},
			{'name':'compare',},
			{'name':'stage3',},
		],
	},
]



'''
stages = [
	{ #Stage 0
		'components':[
			{'name':'__input_stage__'},
		],
	},
	{ #Stage 1
		'components':[
			{'name':'module2','suffix':'A','override_input':{'D':'D1'}},
			{'name':'module2','suffix':'B','override_input':{'D':'D2'}},
			{'name':'module1'},
		],
	},
	{ #Stage 2
		'components':[
			{'name':'moduleZ'},
		],
	},
]
stages = [
	{ #Stage 0
		'components':[
			{'name':'__input_stage__'},
		],
	},
	{ #Stage 1
		'components':[
			{'name':'prep'},
		],
	},
	{ #Stage 2
		'components':[
			{'name':'convert','suffix':'1','override_input':{'in':'C'}}
		],
	},
	{ #Stage 3
		'components':[
			{'name':'end'},
		],
	},
]'''
