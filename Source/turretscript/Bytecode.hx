package turretscript;

enum Comparison
{
	Always;
	Eq;
	Neq;
	Gt;
	Gte;
	Lt;
	Lte;
}

enum Operand
{
	Register(index: Int);
	Literal(value: Int);
	Label(name: String);
}

enum Operator
{
	Skip;
	Jump(comparison: Comparison, target: Operand);
	Compare(lhs: Operand, rhs: Operand);
	Move(src: Operand, dst: Operand);
	Add(lhs: Operand, rhs: Operand);
	Wait(cycles: Operand);
}

class Instruction
{
	public var label: Null<String>;
	public var op: Operator;

	public function new(label: Null<String>, op: Operator)
	{
		this.label = label;
		this.op = op;
	}
}