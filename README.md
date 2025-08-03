# DSL Grammar and Rego Examples

This repository demonstrates a simple domain‑specific language (DSL) for expressing
high‑level data masking policies and shows how those DSL statements can be
implemented using [Rego](https://www.openpolicyagent.org/), the policy language
of the Open Policy Agent (OPA).  The DSL allows authors to express policies
without having to write Rego directly; instead, a small grammar is provided
along with samples showing how the DSL statements map to Rego rules.

## Motivation

When dealing with sensitive information such as personally identifiable
information (PII), it is often necessary to mask or redact fields before they
leave a service.  OPA supports decision masking through the `mask` rule,
which can remove fields entirely or replace their values with a constant
placeholder.  For example, the Styra documentation notes that a decision
masking policy can remove an `access_token` field from the decision input
using the rule `mask["/input/access_token"]`【991115369341676†L64-L131】.

The DSL presented here provides a concise way to declare such policies.  A
statement like:

```
mask_if(label == "PII")
```

expresses that if the label on the input is `"PII"`, certain fields should be
masked.  The grammar below describes the formal structure of the DSL.

## DSL Grammar

The DSL is defined in Extended Backus–Naur Form (EBNF).  The syntax draws
inspiration from the Rego grammar specified in the OPA policy reference【36224134486143†L389-L447】,
but it is intentionally much simpler.  In particular, the DSL currently
supports only `mask_if` statements with boolean expressions composed of
equality and inequality comparisons joined with `and` and `or`.

```
policy      ::= statement*
statement   ::= mask_if
mask_if     ::= "mask_if(" condition ")"
condition   ::= expression ( ( "and" | "or" ) expression )*
expression  ::= operand operator operand
operand     ::= identifier | string | number
operator    ::= "==" | "!=" | "<" | "<=" | ">" | ">="
identifier  ::= letter ( letter | digit | "_" )*
string      ::= '"' characters '"'
number      ::= [ '-' ] digit+

letter      ::= 'A'..'Z' | 'a'..'z'
digit       ::= '0'..'9'
```

* A **policy** is a sequence of zero or more statements.
* A **mask_if** statement contains a condition enclosed in parentheses.
* A **condition** is one or more boolean expressions separated by
  logical `and`/`or` operators.
* An **expression** compares two operands using one of the supported
  comparison operators.

This simple grammar can be extended in the future to support additional
statements or more complex conditions.

## Example DSL Statements

* `mask_if(label == "PII")` — mask when the input’s label is exactly `"PII"`.
* `mask_if(label == "PII" and category != "public")` — mask when the label
  indicates PII and the data category is not public.
* `mask_if(score > 0.8 or flagged == true)` — mask when either the risk score
  exceeds `0.8` or the `flagged` field is true.

## Rego Sample

The [`mask_example.rego`](mask_example.rego) file demonstrates how a `mask_if`
statement can be implemented in Rego.  The Rego policy uses the `mask` rule
defined by OPA’s decision masking facility.  The example masks three fields
(`email`, `phone`, and `ssn`) when the input includes a label equal to
`"PII"`.

## License

This project is licensed under the Apache 2.0 License.  See the [LICENSE](LICENSE)
file for details.
