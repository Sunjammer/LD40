package coldBoot.cpu;

import coldBoot.cpu.Bytecode;

using Lambda;

interface IRegister
{
	public function read(): Int;
	public function write(value: Int): Void;
}

class LocalRegister implements IRegister
{
	private var value: Int;

	public function new() {
		value = 0;
	}

	public function read(): Int {
		return value;
	}

	public function write(v: Int) {
		value = v;
	}
}

class Machine
{
	var program: Array<Instruction>;
	var pc: Int;
	var registers: Array<IRegister>;
	var labelCache: Map<String, Int>;

	var compareLeft: Int = 0;
	var compareRight: Int = 0;

	public function new()
	{
		this.registers = [];
		this.pc = 0;
		setProgram([]);
	}

	public function setProgram(program: Array<Instruction>) {
		this.program = program;
		this.pc = 0;
		setupLabelCache();
	}

	public function setRegisters(registers: Array<IRegister>) {
		this.registers = registers;
	}

	function setupLabelCache() {
		labelCache = new Map();
		program.mapi(function(lineNumber, instr) {
			if (instr.label != null)
				labelCache[instr.label] = lineNumber;
		});
	}

	function readOperand(operand: Operand): Int {
		return switch (operand) {
			case Operand.Literal(v): v;
			case Operand.Register(r): registers[r].read();
			case _: throw "No way jose";
		}
	}

	function register(index: Int): IRegister {
		return registers[index];
	}

	function getPcForLabel(label: String): Null<Int> {
		return labelCache.get(label);
	}

	function testComparison(cmp: Comparison): Bool {
		var lhs = compareLeft;
		var rhs = compareRight;

		return switch(cmp) {
			case Comparison.Always: true;
			case Comparison.Eq: lhs == rhs;
			case Comparison.Neq: lhs != rhs;
			case Comparison.Lt: lhs < rhs;
			case Comparison.Lte: lhs <= rhs;
			case Comparison.Gt: lhs > rhs;
			case Comparison.Gte: lhs >= rhs;
		}
	}

	public function step()
	{
		var instr = program[pc];
		var nextPc = pc + 1;
		if (nextPc >= program.length)
			nextPc = 0;

		switch(instr.op) {
			case Operator.Move(src, Operand.Register(reg)): {
				var value = readOperand(src);
				register(reg).write(value);
			}
			case Operator.Compare(lhs, rhs): {
				compareLeft = readOperand(lhs);
				compareRight = readOperand(rhs);
			}
			case Operator.Jump(comparison, Operand.Label(target)): {
				if (testComparison(comparison)) {
					nextPc = getPcForLabel(target);
				}
			}
			case Operator.Add(Operand.Register(ri), rhs): {
				var reg = register(ri);
				reg.write(reg.read() + readOperand(rhs));
			}

			case _: throw "Unimplemented operator " + instr.op.getName();
		}

		pc = nextPc;
	}
}