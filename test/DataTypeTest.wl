(* ::Package:: *)

BeginPackage["DataTypeTest`"];
Construct[ClearAll, Context[] <> "*"];


Begin["`Private`"];


Construct[ClearAll, Context[] <> "*"];
TestedContext = "DataType`";
(*Tests::usage = StringTemplate["Tests for `` context."][TestedContext];*)
Needs[TestedContext];


Tests = {

VerificationTest[
	AssociationSameQ @@@ {
		{<|"a" -> 1, "b" -> 2|>, <|"b" -> 2, "a" -> 1 |>},
		{<|"a" -> 1, "b" -> 2|>, <|"b" -> 1, "a" -> 2 |>},
		{<|"a" -> 1, "b" -> 2|>, <|"a" -> 2 |>},
		{<|"a" -> 1, "b" -> 2|>, <||>},
		{<|"a" -> 1, "b" -> 2|>, <|"b" -> 2, "c" -> 3|>},
		{<||>, <||>}
	},
	{True, False, False, False, False, True},
	TestID -> "AssociationSameQ"
],

VerificationTest[
	DeclareType[Student, <|"id" -> _?NumberQ, "name" -> _String, "sex" -> "Male"|"Female", "courses"-> Association[(_Integer->_String)...]|>];
	stu1 = Student[<|"id" -> 1, "name" -> "John Doe", "sex" -> "Male"|>];
	stu1 /@ {"id","name", "sex"},
	{1, "John Doe", "Male"},
	TestID -> "Simple Getters"
],

VerificationTest[
	Keys[Student],
	{"id", "name", "sex", "courses"},
	TestID -> "Keys"
],

VerificationTest[
	KeyPatterns[Student],
	<|"id" -> _?NumberQ, "name" -> _String, "sex" -> "Male"|"Female", "courses"-> Association[(_Integer->_String)...]|>,
	TestID -> "KeyPatterns"
],

VerificationTest[
	stu1 = Student[<|"id" -> 1, "name" -> "John Doe", "sex" -> "Man"|>];
	stu1["sex"],
	Missing["PatternMismatch", {"Man", "Male"|"Female"}],
	TestID -> "Getter Type Check"
],

VerificationTest[
    ConstructType[1, _String|_Integer],
    1,
    TestID -> "Simple Constructor 1"
],

VerificationTest[
    ConstructType[1.1, x:(_String|_Integer)],
    Missing["ConstructorNotFound", {1.1, (_String|_Integer)}],
    TestID -> "Simple Constructor 2"
],

VerificationTest[
    ConstructType[2, _String|_?EvenQ],
    2,
    TestID -> "Simple Constructor 3"
],

VerificationTest[
    ConstructType[<|"id" -> 1, "name" -> "John Doe", "sex" -> "Male", "courses"-> <|1-> "ECON101", 2->"COMP102", 3->"PHYS201"|>|>, _Student],
    Student[<|"id" -> 1, "name" -> "John Doe", "sex" -> "Male", "courses"-> <|1-> "ECON101", 2->"COMP102", 3->"PHYS201"|>|>],
    TestID -> "Type Constructor 1"
],

VerificationTest[
    ConstructType[<|"id" -> 1, "name" -> "John Doe", "sex" -> "Man"|>, Student],
    Student[<|"id" -> 1, "name" -> "John Doe", "sex" -> Missing["ConstructorNotFound","Man"]|>],
    TestID -> "Type Constructor 2"
],

VerificationTest[
    DeclareType[LspPosition, <|"line" -> _Integer, "character" -> _Integer|>];
    DeclareType[LspRange, <|"start" -> _LspPosition, "end" -> _LspPosition|>];
    DeclareType[TextDocumentContentChangeEvent, <|"range" -> _LspRange, "rangeLength" -> _Integer, "text" -> _String|>];
    ConstructType[{<|
        "range" -> <|
            "start" -> <|
                "line" -> 9,
                "character" -> 0
            |>,
            "end" -> <|
                "line" -> 9,
                "character" -> 0
            |>
        |>,
        "rangeLength" -> 0,
        "text" -> "\r\n"
    |>}, {___TextDocumentContentChangeEvent}],
    {TextDocumentContentChangeEvent[<|
        "range" -> LspRange[<|
            "start" -> LspPosition[<|
                "line" -> 9,
                "character" -> 0
            |>],
            "end" -> LspPosition[<|
                "line" -> 9,
                "character" -> 0
            |>]
        |>],
        "rangeLength" -> 0,
        "text" -> "\r\n"
    |>]},
    TestID -> "Nested Construct Constructor 1"
],

VerificationTest[
    ConstructType[<|"id" -> 1, "name" -> "John Doe", "sex" -> "Man"|>, Student],
    Student[<|"id" -> 1, "name" -> "John Doe", "sex" -> Missing["ConstructorNotFound","Man"]|>],
    TestID -> "List Constructor 1"
],

VerificationTest[
	stu1 = Student[<|"id" -> 1, "name" -> "John Doe", "sex" -> "Male", "courses"->{"ECON101","COMP102","PHYS201"}|>];
	ReplaceKey[stu1, {"courses", 2}->"COMP202"],
	Student[<|"id" -> 1, "name" -> "John Doe", "sex" -> "Male","courses"->{"ECON101","COMP202","PHYS201"}|>],
	TestID -> "Replace List"
],

VerificationTest[
	stu1 = Student[<|"id" -> 1, "name" -> "John Doe", "sex" -> "Male", "courses"-> <|1-> "ECON101", 2->"COMP102", 3->"PHYS201"|>|>];
	stu1 = ReplaceKey[stu1, {"courses", 2}->"COMP202"];
	ContainsExactly[Normal @ stu1["courses"], Normal @ <|1-> "ECON101", 2->"COMP202", 3->"PHYS201"|>],
	True,
	TestID -> "Replace Association"
],

VerificationTest[
	stu1 = Student[<|"id" -> 1, "name" -> "John Doe", "sex" -> "Male", "courses"-> <|1-> "ECON101", 2->"COMP102", 3->"PHYS201"|>|>];
	stu1 // ReplaceKey[{"courses", 2}->"COMP202"] // ReplaceKey["name" -> "Long"],
	Student[<|"id" -> 1, "name" -> "Long", "sex" -> "Male", "courses"-> <|1-> "ECON101", 2->"COMP202", 3->"PHYS201"|>|>],
	TestID -> "Curried ReplaceKey"
],

VerificationTest[
	DeclareType[Class, <|"id" -> _Integer, "students" -> _Association|>];
	class1 = Class[<|"id"->1, "students"-> <||>|>];
	students = class1["students"];
	students~AssociateTo~(
	"ken" -> 
	Student[<|"id" -> 1, "name" -> "John Doe", "sex" -> "Male", "courses"-> <|1-> "ECON101", 2->"COMP102", 3->"PHYS201"|>|>]
	);
	class1 = ReplaceKey[class1, "students"-> students];
	class1["students"]["ken"]["courses"],
	<|1 -> "ECON101", 2 ->"COMP102", 3 ->"PHYS201"|>,
	TestID -> "Association of DataType"
],

VerificationTest[
	studentEmpty = Student[<|"id" -> 5|>];
	studentEmpty @@@ {{"id", 1}, {"name", "Jane Doe"}, {"sex", "Female"}, {"courses", <||>}},
	{5, "Jane Doe", "Female", <||>},
	TestID -> "Getter with default value"
],

VerificationTest[
    TypeUsage[Student, "types a student."];
    Student::usage,
    "Student[<|id -> _?NumberQ, name -> _String, sex -> Male | Female, courses -> Association[(_Integer -> _String)...]|>] types a student.",
    TestID -> "Type usage 1"
],

VerificationTest[
    TypeUsage[VoidType, "is a void type."];
    DeclareType[VoidType, <||>];
    VoidType::usage,
    "VoidType[<||>] is a void type.",
    TestID -> "Type usage 2"
]

};

Sow[#, "WolframLanguageServer`Test`DataTypeTest`"]& /@ Tests;


End[];


EndPackage[];
