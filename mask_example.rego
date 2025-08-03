package example.masking

################################################################################
# Example Rego policy implementing a `mask_if` DSL statement.
#
# This policy uses OPA’s decision masking mechanism to redact sensitive fields
# when the input contains a `label` equal to "PII".  When the condition is
# satisfied, it generates a `mask` entry for each field listed in
# `mask_fields`.  Each entry instructs OPA to perform an "upsert" operation,
# replacing the field’s value with a constant mask value ("**MASKED**").
#
# For more information about decision masking in OPA, see Styra’s documentation
# which explains how the `mask` rule can remove or redact fields【991115369341676†L64-L131】.
################################################################################

## List of fields to mask when the condition is true.  This list can be
## customized to include any sensitive fields present in the input.  In this
## example we assume `email`, `phone`, and `ssn` should be redacted.
mask_fields := ["email", "phone", "ssn"]

## The mask rule defines a set of operations.  Each value in the set is a
## dictionary containing the operation (`op`), the JSON Pointer path to
## modify (`path`), and the replacement value (`value`).  When the input
## contains a `label` equal to "PII", the rule iterates over each
## entry in `mask_fields` and constructs a corresponding `mask` entry.
##
## - `op: "upsert"` instructs OPA to replace the existing value (or insert
##   it if missing).
## - `path` uses a format string to build the JSON Pointer for the field.
## - `value` is the mask string used as a placeholder.
mask[{"op": "upsert", "path": path, "value": value}] {
    input.label == "PII"
    field := mask_fields[_]
    path := sprintf("/input/%s", [field])
    value := "**MASKED**"
}
