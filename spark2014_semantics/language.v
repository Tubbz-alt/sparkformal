(** This module is from Kansas State University. It is the current
    (may 2013) target Coq format of the translator from Ada xml ast to
    coq.

    Copyright and licence to be determined by KSU. Any transformation
    of this file is experimental and cannot reach publicity without
    permission of KSU. *)

Require Export ZArith. 
Require Export Coq.Lists.List.
Require Export Coq.Bool.Bool.
Require Export Coq.Strings.String.
(* coqdoc language.v values.v environment.v semantics.v wellformedness.v propertyProof.v  -toc --no-lib-name *)

(** * SPARK Subset Language *)
Inductive mode: Type := 
    | In: mode
    | Out: mode
    | InOut: mode.

Inductive typ: Type := 
    | Tint: typ
    | Tbool: typ.

(** Distinct number labeled for each AST node *)
Definition astnum := nat.

(** In CompCert, Cminor uses non-negative values to represent identifiers; 
    we follow this style by using natural numbers to represent identifiers/names.
*)
Definition idnum := nat.

Definition procnum := nat.

Definition typenum := nat.

Definition typedeclnum := astnum.

Definition aspectnum := nat.

Definition typeuri := string.

Record type_table: Type := mktype_table{
    tt_exptype_table: list (astnum * typenum);
    tt_typename_table: list (typenum * (typeuri * option typedeclnum))
}.

(** ** Constants *)
Inductive constant: Type := 
	| Ointconst: Z -> constant
        | Oboolconst: bool -> constant.

(** Basic unary/binary operators *)
Inductive unary_operation: Type := 
        | Onot: unary_operation.
(*     
        | Onegint: unary_operation
	| Oposint: unary_operation. *)

(* now only consider simple binary_operator *)
Inductive binary_operation: Type := 
	| Ceq: binary_operation
	| Cne: binary_operation
	| Cgt: binary_operation
	| Cge: binary_operation
	| Clt: binary_operation
	| Cle: binary_operation
	| Oand: binary_operation
	| Oor: binary_operation
	| Oadd: binary_operation
	| Osub: binary_operation
	| Omul: binary_operation
	| Odiv: binary_operation.

(** ** Expressions *)
Inductive expr: Type := 
	| Econst: astnum -> constant -> expr
	| Evar: astnum -> idnum -> expr
	| Ebinop: astnum -> binary_operation -> expr -> expr -> expr
	| Eunop: astnum -> unary_operation -> expr -> expr.

(** ** Statements *)
Inductive stmt: Type := 
	| Sassign: astnum -> idnum -> expr -> stmt
	| Sifthen: astnum -> expr -> stmt -> stmt
	| Swhile: astnum -> expr -> stmt -> stmt
	| Sseq: astnum -> stmt -> stmt -> stmt.
(*	| Sreturn: astnum -> option (expr) -> stmt 
	| Sassert: astnum -> expr -> stmt
	| Sloopinvariant: astnum -> expr -> stmt. *)

Record param_specification: Type := mkparam_specification{
	param_astnum: astnum;
        param_ident: idnum;
	param_typenum: typenum;
	param_mode: mode;
	param_init: option (expr)
}.

Record aspect_specification: Type := mkaspect_specification{
	aspect_astnum: astnum;
	aspect_mark: aspectnum;
	aspect_definition: expr
}.

(* Local variables declarations used in the procedure/function body *)
Record local_declaration: Type := mklocal_declaration{
	local_astnum: astnum;
        local_ident: idnum;
	local_typenum: typenum;
	local_init: option (expr)
}.

Record procedure_body: Type := mkprocedure_body{
	proc_astnum: astnum;
	proc_name: procnum;
	proc_specs: list aspect_specification;
	proc_params: list param_specification;
	proc_loc_idents: list local_declaration;
	proc_body: stmt
}.

Record function_body: Type := mkfunction_body{
	fn_astnum: astnum;
	fn_name: procnum;
	fn_ret_type: typ;
	fn_specs: list aspect_specification;
	fn_params: list param_specification;
	fn_loc_idents: list local_declaration;
	fn_body: stmt
}.

(** ** Compilation unit: subprogram *)
Inductive subprogram: Type := 
	| Sproc: astnum -> procedure_body -> subprogram
(*	| Sfunc: astnum -> function_body -> subprogram *).

Inductive unit_declaration: Type := 
	| UnitDecl: astnum -> subprogram -> unit_declaration.

Inductive compilation_unit: Type := 
	| CompilationUnit: astnum -> unit_declaration -> type_table -> compilation_unit.

