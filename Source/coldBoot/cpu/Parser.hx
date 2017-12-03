package coldBoot.cpu;

import coldBoot.cpu.Bytecode;

using StringTools;
using Lambda;
using Std;

class Parser {
	public static function parse(program: String) {
		return program.split("\n").mapi(function(lineNumber, line) {
			var parsed = new InstructionParser(line).parse();
			switch (parsed) {
				case InstructionParserResult.Empty: return new Instruction(null, Operator.Skip);
				case InstructionParserResult.Invalid: {
					trace("Invalid opcode");
					return new Instruction(null, Operator.Skip);
				};
				case InstructionParserResult.Success(instr): return instr;
			}
		});
	}
}

private class InstructionParser
{
	var tokens: Array<String>;

	static var tokenSplitRegex = ~/[ \t]+/g;

	public function new(line: String)
	{
		trace(line);
		tokens = tokenize(line);
		trace(tokens);
	}

	public function parse(): InstructionParserResult {
		if (tokens.length == 0)
			return InstructionParserResult.Empty;

		var label: Null<String> = null;

		if (tokens[0].startsWith("@")) {
			label = tokens.shift().substring(1);
		}
		
		if (tokens.length == 0)
			return InstructionParserResult.Invalid;

		var mnemonic = tokens.shift();

		var op = parseOperator(mnemonic);
		
		return InstructionParserResult.Success(
			new Instruction(label, op)
		);
	}
	
	function parseOperator(mnemonic: String) {
		switch (mnemonic) {
			case "mov": {
				var operands = parseOperands(2);
				var src = operands[0];
				var dst = operands[1];

				return Operator.Move(src, dst);
			};
			case "cmp": {
				var operands = parseOperands(2);
				return Operator.Compare(operands[0], operands[1]);
			};
			case "jmp": return parseJumpOperator(Comparison.Always);
			case "jeq": return parseJumpOperator(Comparison.Eq);
			case "jne": return parseJumpOperator(Comparison.Neq);
			case "jgt": return parseJumpOperator(Comparison.Gt);
			case "jge": return parseJumpOperator(Comparison.Gte);
			case "jlt": return parseJumpOperator(Comparison.Lt);
			case "jle": return parseJumpOperator(Comparison.Lte);
			case "add": {
				var operands = parseOperands(2);
				var lhs = operands[0];
				if(!lhs.match(Operand.Register(_)))
					throw "Left-hand side of an addition must be a register";
				var rhs = operands[1];
				return Operator.Add(lhs, rhs);
			}

			default: throw "Invalid opcode '" + mnemonic + "'";
		}
	}

	function parseJumpOperator(cond: Comparison): Operator {
		var target = parseOperands(1)[0];
		if (!target.match(Operand.Label(_)))
			throw "Jump instruction takes a single label operand";
		return Operator.Jump(cond, target);
	}

	function parseOperands(num: Int): Array<Operand> {
		if(tokens.length != num) {
			throw "Expected " + num + " operands, got " + tokens.length;
		}

		return tokens.map(parseOperand);
	}

	static function parseOperand(operand: String): Operand
	{
		if (operand.startsWith("$")) {
			var regIndex = operand.substring(1).parseInt();
			if (regIndex == null)
				throw "Invalid register operand";
			return Operand.Register(regIndex);
		}
		if (operand.startsWith("@"))
			return Operand.Label(operand.substring(1));
		
		var literal = operand.parseInt();
		if (literal == null)
			throw "Invalid number literal";

		return Operand.Literal(literal);
	}

	static function tokenize(line: String) {
		return tokenSplitRegex.split(line.trim());
	}
}

enum InstructionParserResult {
	Empty;
	Invalid;
	Success(instr: Instruction);
}