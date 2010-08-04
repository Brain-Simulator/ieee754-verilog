'''module_name = 'ieee_adder'
file_input = 'ieee_stages.v'
file_output = 'ieee_adder.v'
clock_name = 'clock_in'
inputs = [('bit','add_sub_bit'), ('number','inputA'), ('number','inputB'), ('bit', clock_name)]
outputs = [('number','outputC')]
'''
from __future__ import print_function
pipeline_name = 'emir'
file_input = 'emir_stages.v'
file_output = 'emir_gen.v'
clock_name = 'clock_in'

widths = {
	'bit' : '',
	'w3' : '[0:2]',
}
inputs = [('bit','A'), ('bit','B'), ('bit', clock_name)]
outputs = [('bit','Z'),('bit','Y')]

import re
import string
import random
import sys
from parselib import readNoComments, readModules
from copy import copy

out = open(file_output,'w')
out.write("////////////////////////////////////////////\n")
out.write("//                                        //\n")
out.write("//  THIS FILE IS AUTOMATICALLY GENERATED  //\n")
out.write("//     BY generate.py, DO NOT EDIT!       //\n")
out.write("//                                        //\n")
out.write("////////////////////////////////////////////\n")
out.write('`include "defines.v"\n')

out.write("module "+pipeline_name+"(" + 
	",".join(name for type, name in inputs + outputs) + ");\n")

for type,input in inputs:
	out.write("\tinput "+widths[type]+" " + input + ";\n")

for type,output in outputs:
	out.write("\toutput "+widths[type]+" " + output + ";\n")

file = readNoComments(open(file_input))
modules = readModules(file, pipeline_name, widths)

modules['__input_stage__'] = {
	'name':'__input_stage__',
	'inputs':[],
	'outputs' : inputs, #imaginary module which provides global inputs
}
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
'''

stages = [
	{ #Stage 0
		'components':[
			{'name':'__input_stage__'},
		],
	},
	{ #Stage 0
		'components':[
			{'name':'prep'},
			{'name':'end'},
		],
	},
]

#populate var_appear and comp_appear
var_appear = {}
comp_appear = {}
for stage_num, stage in enumerate(stages):
	for component in stage['components']:
		name = component['name']
		if name not in modules:
			raise Exception("Could not find module %s", name)
		module = modules[name]
		if 'suffix' in component:
			name += component['suffix']
		
		#check for a duplicate component
		if name in comp_appear:
			raise Exception('Duplicate name module "%s"' % name)
		component['module_name'] = name
		map_inputs = {}
		map_outputs = {}
		minputs = []
		moutputs = []
		#for all inputs of this instance of module
		override = (component['override_input'] 
			if 'override_input' in component else None)
		for type, input in module['inputs']:
			print(name, ' input ', input)
			if override and input in override:
				input_name = override[input]
			else:
				input_name = input
			map_inputs[input_name] = input
			minputs.append((type, input_name))
		
		#for all outputs in this instance of module
		for type, output_orig in module['outputs']:
			output = output_orig
			if 'suffix' in component:
				output += component['suffix']
			print(name, ' output ', output)
			if output not in var_appear:
				var_appear[output] = []
			else:
				#check if there is collision?
				if var_appear[-1]['stage'] == stage_num:
					raise Exception("Duplicate output %s in stage %d" %
						(output, stage_num))
			#add output to var_appear
			var_appear[output].append({
					'stage':stage_num,
					'name':name,
					'module_name':component['name'],
					'output_name':output_orig,
					'type':type,
					'end_stage':stage_num,
				})
			map_outputs[output] = output_orig
			moutputs.append((type,output))
		#add this instance of module
		comp_appear[name] = {
			'stage':stage_num,
			'module_name':component['name'],
			'inputs':minputs,
			'outputs':moutputs,
			'map_inputs':map_inputs,
			'map_outputs':map_outputs,
			'added':False,
			'on_stack':False,
		}

def find_next_var(name, var_appear, start_stage):
	if name not in var_appear:
		return None
	for var in reversed(var_appear[name]):
		if var['stage'] <= start_stage:
			return var
	return None

def add_to_stack(variables, stack, stage_num):
	count = 0
	for type, output in variables:
		var = find_next_var(output, var_appear, stage_num)
		if var is None:
			raise Exception("%s not found" % output)
		else:
			var['end_stage'] = max(var['end_stage'], stage_num)
			name = var['name']
			if name not in comp_appear:
				raise Exception("%s not in comp_appear"%name)
			module_name = var['module_name']
			stage = var['stage']
			if not comp_appear[name]['on_stack']:
				stack.append(name)
				comp_appear[name]['on_stack'] = True
				count += 1
	return count

#add new column to stages
for stage in stages:
	stage['order'] = []

#processing stack
stack = []
add_to_stack(outputs, stack, len(stages))
while len(stack) > 0:
	name = stack[-1]
	if comp_appear[name]['added']:
		stack.pop()
		continue
	count = add_to_stack(comp_appear[name]['inputs'], 
		stack, comp_appear[name]['stage'])
	if count == 0:
		print('adding module',name)
		stage = comp_appear[name]['stage']
		stages[stage]['order'].append(name)
		comp_appear[name]['added'] = True
		stack.pop()

print("=======COMPONENTS=========")
for name in comp_appear:
	print('comp',name)
	print(' ',comp_appear[name])

print("=======VARIABLES=========")
for name in var_appear:
	print('var', name)
	print(' ',var_appear[name])

print("=======STAGES=========")
for stage_num, stage in enumerate(stages):
	print('Number:', stage_num, '=>', stage['order'])

print("================")
# a list of variables that need to be passed further down the pipeline
active_vars = [input for type, input in inputs]
last_stage = len(stages)-1

#write output
for stage_num, stage in enumerate(stages[1:], start = 1):
	print('stage',stage_num,stage)
	out.write("\t/////////////\n")
	out.write("\t// STAGE %d //\n" % stage_num)
	out.write("\t/////////////\n")
	for name in stage['order']:
		instance = comp_appear[name]
		out.write("\t//Outputs of module '%s' with instance '%s'\n"
			% (instance['module_name'], name))
		for type, output in instance['outputs']:
			out.write("\twire %s s%do_%s;\n" % 
				(widths[type], stage_num, output))
	for name in stage['order']:
		instance = comp_appear[name]
		out.write("\t//Calling instance '%s'\n" % (name))
		out.write("\t%s_%s S%d_%s_%s (\n\t\t" %( 
			pipeline_name, instance['module_name'], 
			stage_num, pipeline_name ,name))
		inout = []
		#connect inputs of instance
		for type, input in comp_appear[name]['inputs']:
			var = find_next_var(input, var_appear, stage_num)
			#find the name of original input
			if input in comp_appear[name]['map_inputs']:
				input_orig = comp_appear[name]['map_inputs'][input]
			else:
				input_orig = input
			
			if var['stage'] != stage_num:
				if var['stage'] == 0:
					input_name = input
				else:
					input_name = 's%si_%s'%(stage_num, input)
			else:
				input_name = 's%so_%s'%(var['stage'], input)
			inout.append("/*input*/.%s(%s)" %(input_orig, input_name))
		#connect outputs of instance
		for type, output in comp_appear[name]['outputs']:
			#find the name of original output
			if output in comp_appear[name]['map_outputs']:
				output_orig = comp_appear[name]['map_outputs'][output]
			else:
				output_orig = output
			
			output_name = "s%do_%s" % (stage_num, output)
			inout.append("/*output*/.%s(%s)" % (output_orig, output_name))
			active_vars.append(output)
		out.write(",\n\t\t".join(inout))
		out.write("\n\t);\n")
	new_active_vars = []
	for varname in active_vars:
		var = find_next_var(varname, var_appear, stage_num)
		print(varname, var['end_stage'])
		if var['end_stage'] > stage_num:
			new_active_vars.append(varname)
			if var['stage'] < stage_num:
				out.write("\twire %s s%do_%s;\n" 
					%(widths[var['type']], stage_num, varname))
				out.write("\tassign s%do_%s = s%di_%s;\n"
					%(stage_num, varname, stage_num, varname))
	active_vars = new_active_vars
	
	add_ffs = stage_num < last_stage
	if add_ffs:
		out.write("\t//Connect stage %s to stage %d\n" 
			%(stage_num, stage_num + 1))
		for varname in active_vars:
			var = find_next_var(varname, var_appear, stage_num)
			out.write("\treg %s s%di_%s;\n"
				%(widths[var['type']], stage_num + 1, varname))
		out.write("\talways @ (posedge %s)\n\tbegin\n" % clock_name)
		for varname in active_vars:
			var = find_next_var(varname, var_appear, stage_num)
			out.write("\t\ts%di_%s <= s%do_%s;\n" % 
				(stage_num + 1, varname, stage_num, varname))
		out.write("\tend\n")
out.write("\t//Connect stage %d to pipeline output\n" % (last_stage))
for varname in active_vars:
	out.write("\tassign %s = s%do_%s;\n" %(varname, last_stage, varname))
out.write("endmodule\n")

