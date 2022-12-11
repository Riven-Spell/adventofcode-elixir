defmodule BasicMath do
	def gcd(a, 0), do: a
	def gcd(0, b), do: b
	def gcd(a, b), do: gcd(b, rem(a, b))

	def lcm(0, 0), do: 0
	def lcm(a, b) when not (is_list(a) or is_list(b)), do: a * b / gcd(a, b)
	def lcm(a, [b | rem]), do: lcm(trunc(lcm(a, b)), rem)
	def lcm(a, []), do: a
	def lcm([a, b]), do: lcm(a, b)
	def lcm([a, b | rem]), do: lcm(trunc(lcm(a, b)), rem)
end
