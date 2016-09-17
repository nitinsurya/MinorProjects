; Templates

;TODOS: curry complexity fuzzify, time duration fuzzify, quatity fuzzify
;       serve temp - hot/cold, type of food: dessert, entree, starter, misc

(import nrc.fuzzy.*)
(import nrc.fuzzy.jess.*)

(load-package nrc.fuzzy.jess.FuzzyFunctions)

; will contain the fuzzy variable for temperature
(deftemplate fuzzyTemp
    (slot temp))

; will contain the fuzzy variable for quantity
(deftemplate fuzzyQuant
    (slot quant))

; will contain the fuzzy variable for complexity
(deftemplate fuzzyComplexity
    (slot complex))

; will contain various ingredients available for cooking
(deftemplate ingredient
    (slot name)
    (slot available (default "n"))
    (slot quantity))

; contains details about each curry
(deftemplate curry
    (slot name)
    (slot ingredients)
    (slot recipe)
    (slot duration)
    (slot servetemp); temperature at which it is served
    (slot complexity)); complexity of dish to prepare

; will save the names of all the curries possible with the given ingredients
(deftemplate possibleCurries
    (slot name))

(deftemplate curryFuzzytempVar
    (slot name)
    (slot temp))

; contains a list of ingredients possible
(deftemplate possibleIngredients
    (slot name)
    (slot askquant))

; random application related variables
(deftemplate appVars
    (slot name)
    (slot val))



; Functions

; asserts a new curry possible
(deffunction addPossibleCurries (?name)
    (assert (possibleCurries (name ?name))))

; asserts a new ingredient available
(deffunction addIngredient (?name ?available ?quantity)
    "Adds a new ingradents with the name passed"
    (assert (ingredient (name ?name) (available ?available) (quantity ?quantity)))
    (return))

; used to check if ?answer matches the ?type passed
(deffunction typeCheck (?answer ?type)
    "Check that the answer has the right form"
    (if (eq ?type yes-no) then
        (return (or (eq ?answer yes) (eq ?answer no) (eq ?answer y) (eq ?answer n))))
    (if (eq ?type f-p) then
        (return (or (eq ?answer f) (eq ?answer few) (eq ?answer p) (eq ?answer plenty))))
    (if (eq ?type numeric) then
        (return (numberp ?answer)))
    (return (> (str-length ?answer) 0)))

; asks user the question and reads input
(deffunction ask-user (?question ?type)
    "Ask a question, and return the answer"
    (bind ?answer "")
    (while (not (typeCheck ?answer ?type)) do
        (printout t ?question)
        (if (eq ?type yes-no) then
            (printout t " (y/n)"))
        (printout t ": ")
        (bind ?answer (read)))
    (return ?answer))

; initializes or updates an application variable
(deffunction setAppVar (?varname ?varval)
    (assert (MAIN::appVars (name ?varname) (val ?varval)))
    (return))

; return tht value of an application variable, ?varname.
(deffunction getAppVar (?varname ?type)
    (bind ?result (run-query* customQueries::getAppVarVal ?varname))
    (while (?result next) do
        (if (eq ?type numeric) then
            (return (?result getInt varval))
        else
            (return (?result getString varval))))
    (if (eq ?type numeric) then
        (return -1)
    else
        (return ""))

    )

; function to display all the details of a curry
(deffunction displayCurryResult (?curryname)
    (bind ?result (run-query* customQueries::getCurryByName ?curryname))
    (while (?result next) do
    (printout t "Name: " ?curryname crlf "Ingredients: " (?result getString ingredients)
        crlf "Recipe: " (?result getString recipe) crlf "Duration: " (?result getInt duration) crlf))
    (return))


; Facts: Init Ingradients and curry data

; All possible ingredients
(deffacts ingredientsData
    (possibleIngredients (name "Tomato") (askquant "y"))
    (possibleIngredients (name "Potato") (askquant "y"))
    (possibleIngredients (name "Cucumber") (askquant "y"))
    (possibleIngredients (name "Milk") (askquant "n"))
    (possibleIngredients (name "Brocolli") (askquant "n"))
    (possibleIngredients (name "Eggs") (askquant "n"))
    (possibleIngredients (name "Spinach") (askquant "y"))
    (possibleIngredients (name "Ice Cream") (askquant "y"))
    (possibleIngredients (name "Mango") (askquant "y"))
    (possibleIngredients (name "Lemon") (askquant "n"))
    )

; Including the modules files
(batch "modules.clp")
(reset)
; For automated test cases, uncomment the following two lines and comment the 3rd line
;(batch "testcases.clp")
;(focus startup customQueries curryRules report)
(focus fuzzyVarSetup startup customQueries questions curryRules report)
;(watch all)
(run)
