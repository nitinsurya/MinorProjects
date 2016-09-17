; Includes the rules of the curries

; Based on the ingredients present and the time constraint set, gets the possible curries which can be prepared.
(defmodule curryRules)

    ; asserts various Curries data
    (defrule curriesData
        (declare (salience 10))
        (fuzzyTemp (temp ?ftemp))
        (fuzzyComplexity (complex ?fcomplex))
        =>
        (assert (curry (name "TomatoPotato") (ingredients "Tomato, Potato") (recipe "1. Boil Potato in water for 20min. 2. Heat tomatos. 
            3. Add the boiled Potato to tomatos.") (duration 30) (servetemp (new nrc.fuzzy.FuzzyValue ?ftemp "very hot")) (complexity (new nrc.fuzzy.FuzzyValue ?fcomplex "med"))))

        (assert (curry (name "TPC") (ingredients "Tomato, Potato, Cucumber") (recipe "1. Boil Potato in water for 20min. 2. Heat tomatos.
            3. Prepare Cucumber puree. 4. Add the boiled Potato to tomatos and mix them with Cucumber puree prepared earlier.") 
            (duration 40) (servetemp (new nrc.fuzzy.FuzzyValue ?ftemp "hot")) (complexity (new nrc.fuzzy.FuzzyValue ?fcomplex "med"))))

        (assert (curry (name "SpinachSpecial") (ingredients "Tomato, Spinach, Brocolli, Milk") (recipe "1. Make Tomato puree.
            2. Grind Spinach, Brocolli. 3. Add milk to mixture.
            4. Add the tomato puree with the spinach mixture. 5. Serve the SpinachSpecial with bread toast.") (duration 50)
            (servetemp (new nrc.fuzzy.FuzzyValue ?ftemp "cold")) (complexity (new nrc.fuzzy.FuzzyValue ?fcomplex "hard"))))

        (assert (curry (name "PlainOmlette") (ingredients "Egg") (recipe "1. Break the Egg onto a pan. 2. Heat the egg until it is cooked.")
            (duration 10) (servetemp (new nrc.fuzzy.FuzzyValue ?ftemp "med")) (complexity (new nrc.fuzzy.FuzzyValue ?fcomplex "easy"))))

        (assert (curry (name "TomatoOmlette") (ingredients "Egg, Tomato") (recipe "1. Break the Egg onto a pan. 2. Add the cut Tomato.
            3. Heat the egg until it is cooked.")
            (duration 10) (servetemp (new nrc.fuzzy.FuzzyValue ?ftemp "med")) (complexity (new nrc.fuzzy.FuzzyValue ?fcomplex "easy"))))

        (assert (curry (name "2 Ingredient Ice Cream") (ingredients "Ice cream, Milk, Salt") (recipe "1. Take 2 scoops of ice cream. 2. Add a pinch of salt.
            3. Beat milk with some cream. 4 Add the cream-milk mixture over ice cream and serve it cold.")
            (duration 20) (servetemp (new nrc.fuzzy.FuzzyValue ?ftemp "very cold")) (complexity (new nrc.fuzzy.FuzzyValue ?fcomplex "med"))))

        (assert (curry (name "Mango Sorbet") (ingredients "Mango, Lime juice, Milk") (recipe "1. Take few mangos. 2. Take the juice out of mangos. 3. Add a pinch of salt.
            3. Beat them well. 4 Add some lemon juice to the beaten mango. 5. Freeze it in freezer. 6. Serve it with some cold milk added.")
            (duration 15) (servetemp (new nrc.fuzzy.FuzzyValue ?ftemp "very cold")) (complexity (new nrc.fuzzy.FuzzyValue ?fcomplex "med"))))
        )

    (defrule tomatoPotato
        (declare (auto-focus TRUE)) ; to set focus to this module
        (ingredient (name "Tomato") (quantity ?q1&:(fuzzy-match ?q1 "plenty")))(ingredient (name "Potato")) ; List of ingredients neede
        ?curry <- (MAIN::curry (name "TomatoPotato") (duration ?duration) (servetemp ?tempval) (complexity ?complexval)); getting the curry and its duration
        (appVars (name "cookTime") (val ?cooktime&:(or (eq ?cooktime -1) (<= ?duration ?cooktime)))) ;checking the cooktime constraint
        (appVars (name "prepComplex") (val ?fcomplex&:(or (eq ?fcomplex -1) (fuzzy-match ?complexval ?fcomplex)))); checking the complexity of the dish
        (appVars (name "serveTemp") (val ?val&:(or (eq ?val -1) (fuzzy-match ?tempval ?val)))); temp at which the food is requested to be served
        =>
        (if (> (fuzzy-rule-similarity) 0.5) then ; streamlining the results quality
        (addPossibleCurries ?curry.name))) ; adding the curry to possible curries list

    (defrule TPC
        (declare (auto-focus TRUE))
        (ingredient (name "Tomato") (quantity ?q1&:(fuzzy-match ?q1 "plenty")))
        (ingredient (name "Potato") (quantity ?q2&:(fuzzy-match ?q2 "plenty")))
        (ingredient (name "Cucumber") (quantity ?q3&:(fuzzy-match ?q3 "plenty")))
        ?curry <- (MAIN::curry (name "TPC") (duration ?duration) (servetemp ?tempval) (complexity ?complexval))
        (appVars (name "cookTime") (val ?cooktime&:(or (eq ?cooktime -1) (<= ?duration ?cooktime))))
        (appVars (name "prepComplex") (val ?fcomplex&:(or (eq ?fcomplex -1) (fuzzy-match ?complexval ?fcomplex))))
        (appVars (name "serveTemp") (val ?val&:(or (eq ?val -1) (fuzzy-match ?tempval ?val))))
        =>
        (if (> (fuzzy-rule-similarity) 0.5) then
        (addPossibleCurries ?curry.name)))

    (defrule SpinachSpecial
        (declare (auto-focus TRUE))
        (ingredient (name "Tomato"))(ingredient (name "Milk"))
        (ingredient (name "Spinach") (quantity ?q1&:(fuzzy-match ?q1 "plenty")))(ingredient (name "Brocolli"))
        ?curry <- (MAIN::curry (name "SpinachSpecial") (duration ?duration) (servetemp ?tempval) (complexity ?complexval))
        (appVars (name "cookTime") (val ?cooktime&:(or (eq ?cooktime -1) (<= ?duration ?cooktime))))
        (appVars (name "prepComplex") (val ?fcomplex&:(or (eq ?fcomplex -1) (fuzzy-match ?complexval ?fcomplex))))
        (appVars (name "serveTemp") (val ?val&:(or (eq ?val -1) (fuzzy-match ?tempval ?val))))
        =>
        (if (> (fuzzy-rule-similarity) 0.5) then
        (addPossibleCurries ?curry.name)))

    (defrule PlainOmlette
        (declare (auto-focus TRUE))
        (ingredient (name "Eggs"))
        ?curry <- (MAIN::curry (name "PlainOmlette") (duration ?duration) (servetemp ?tempval) (complexity ?complexval))
        (appVars (name "serveTemp") (val ?val&:(or (eq ?val -1) (fuzzy-match ?tempval ?val))))
        (appVars (name "prepComplex") (val ?fcomplex&:(or (eq ?fcomplex -1) (fuzzy-match ?complexval ?fcomplex))))
        (appVars (name "cookTime") (val ?cooktime&:(or (eq ?cooktime -1) (<= ?duration ?cooktime))))
        =>
        (if (> (fuzzy-rule-similarity) 0.5) then
        (addPossibleCurries ?curry.name)))

    (defrule TomatoOmlette
        (declare (auto-focus TRUE))
        (ingredient (name "Eggs"))(ingredient (name "Tomato"))
        ?curry <- (MAIN::curry (name "TomatoOmlette") (duration ?duration) (servetemp ?tempval) (complexity ?complexval))
        (appVars (name "cookTime") (val ?cooktime&:(or (eq ?cooktime -1) (<= ?duration ?cooktime))))
        (appVars (name "serveTemp") (val ?val&:(or (eq ?val -1) (fuzzy-match ?tempval ?val))))
        (appVars (name "prepComplex") (val ?fcomplex&:(or (eq ?fcomplex -1) (fuzzy-match ?complexval ?fcomplex))))
        =>
        (if (> (fuzzy-rule-similarity) 0.5) then
        (addPossibleCurries ?curry.name)))

    (defrule IceCream2Ing
        (declare (auto-focus TRUE))
        (ingredient (name "Ice Cream") (quantity ?q1&:(fuzzy-match ?q1 "plenty")))(ingredient (name "Milk"))
        ?curry <- (MAIN::curry (name "2 Ingredient Ice Cream") (duration ?duration) (servetemp ?tempval) (complexity ?complexval))
        (appVars (name "cookTime") (val ?cooktime&:(or (eq ?cooktime -1) (<= ?duration ?cooktime))))
        (appVars (name "serveTemp") (val ?val&:(or (eq ?val -1) (fuzzy-match ?tempval ?val))))
        (appVars (name "prepComplex") (val ?fcomplex&:(or (eq ?fcomplex -1) (fuzzy-match ?complexval ?fcomplex))))
        =>
        (if (> (fuzzy-rule-similarity) 0.5) then
        (addPossibleCurries ?curry.name)))

    (defrule MangoSorbet
        (declare (auto-focus TRUE))
        (ingredient (name "Mango") (quantity ?q1&:(fuzzy-match ?q1 "plenty")))(ingredient (name "Lemon"))(ingredient (name "Milk"))
        ?curry <- (MAIN::curry (name "Mango Sorbet") (duration ?duration) (servetemp ?tempval) (complexity ?complexval))
        (appVars (name "cookTime") (val ?cooktime&:(or (eq ?cooktime -1) (<= ?duration ?cooktime))))
        (appVars (name "serveTemp") (val ?val&:(or (eq ?val -1) (fuzzy-match ?tempval ?val))))
        (appVars (name "prepComplex") (val ?fcomplex&:(or (eq ?fcomplex -1) (fuzzy-match ?complexval ?fcomplex))))
        =>
        (if (> (fuzzy-rule-similarity) 0.5) then
        (addPossibleCurries ?curry.name)))

; Setting the initial fuzzy values of the terms
(defmodule fuzzyVarSetup)
    (defrule init
        =>
        ; Setting the temperature fuzzy term
        (bind ?var (new FuzzyVariable "temperature" 0.0 100.0 "Degrees C"))
        (?var addTerm "cold" (new ZFuzzySet 10.0 30.0)); higher to lower
        (?var addTerm "med" (new PIFuzzySet 50.0 40.0)); bell curve type
        (?var addTerm "hot" (new SFuzzySet 70.0 100.0)); lower to higher
        (assert (fuzzyTemp (temp ?var)))

        ; Setting the quantity fuzzy term
        (bind ?var (new FuzzyVariable "quantity" 0.0 10.0 "Units"))
        (?var addTerm "few" (new ZFuzzySet 0 3.0))
        (?var addTerm "med" (new PIFuzzySet 5.0 3.0))
        (?var addTerm "plenty" (new SFuzzySet 7.0 10.0))
        (assert (fuzzyQuant (quant ?var)))
        
        ; Setting the complexity fuzzy term
        (bind ?var (new FuzzyVariable "complexity" 0.0 10.0 "Units"))
        (?var addTerm "easy" (new ZFuzzySet 1.0 3.0)); higher to lower
        (?var addTerm "med" (new PIFuzzySet 5.0 4.0)); bell curve type
        (?var addTerm "hard" (new SFuzzySet 7.0 10.0)); lower to higher
        (assert (fuzzyComplexity (complex ?var)))
        )

; Introduction messages
(defmodule startup)
    (defrule printBanner
         =>
         (printout t "Please enter your name: ")
         (bind ?name (read))
         (printout t "Hello, " ?name "." crlf)
         (printout t "Welcome to the curry advisor" crlf)
         (printout t "Please answer the questions and I will tell you the best curry options available to prepare." crlf crlf)
         )

; Some of the queries required in the application to be run
(defmodule customQueries)
    ; Returns app vars value matching it passed name
    (defquery getAppVarVal
        (declare (variables ?varname))
        (MAIN::appVars (name ?varname) (val ?varval)))

    ; Returns curries matching the passed name
    (defquery getCurryByName
        (declare (variables ?varname))
        (MAIN::curry (name ?varname) (ingredients ?ingredients) (recipe ?recipe) (duration ?duration)))

    ; Returns an iterator of all possible ingredients
    (defquery getAllPosIngredients
        (MAIN::possibleIngredients (name ?iname) (askquant ?askquantval)))

    ; Returns an iterator of all possible curries
    (defquery getSugCurriesIt
        (MAIN::possibleCurries (name ?sugCurName)))

; Asking various questions to get started for evaluation
(defmodule questions)
    ; Asks user the temperature at which the dish is to be served (Fuzzyfied)
    (defrule askServeTempQuestion
        (declare (salience 4))
        =>
        (bind ?servetemp "")
        (bind ?boundSatisfied 0)
        ;(while (and (not (typeCheck ?servetemp numeric)) (> ?servetemp 0) (< ?servetemp 5))
        (while (eq 1 1)
            (printout t "What should be the temperature of the food to be served? (1-6)" crlf "    1. Very Hot"
                crlf "    2. Hot" crlf "    3. Medium" crlf "    4. Cold" crlf "    5. Very Cold" crlf "    6. Any" crlf " > ")
            (bind ?servetemp (read))
            (if (typeCheck ?servetemp numeric) then
                (if(and (> ?servetemp 0) (< ?servetemp 7)) then
                    (break))
            ))

        (if (eq ?servetemp 1) then
            (bind ?finalVal "very hot")
        elif (eq ?servetemp 2) then
            (bind ?finalVal "hot")
        elif (eq ?servetemp 3) then
            (bind ?finalVal "med")
        elif (eq ?servetemp 4) then
            (bind ?finalVal "cold")
        elif (eq ?servetemp 5) then
            (bind ?finalVal "very cold")
        else
            (bind ?finalVal -1)
        )
        (setAppVar "serveTemp" ?finalVal))

    ; Asks user the complexity at which the dish is to be served (Fuzzyfied)
    (defrule askComplexQuestion
        (declare (salience 3))
        =>
        (bind ?complex "")
        (bind ?boundSatisfied 0)
        ;(while (and (not (typeCheck ?servetemp numeric)) (> ?servetemp 0) (< ?servetemp 5))
        (while (eq 1 1)
            (printout t "What should be the complexity of the dish? (1-4)" crlf "    1. Easy"
                crlf "    2. Med" crlf "    3. Hard" crlf "    4. Any" crlf " > " )
            (bind ?complex (read))
            (if (typeCheck ?complex numeric) then
                (if(and (> ?complex 0) (< ?complex 5)) then
                    (break))
            ))

        (if (eq ?complex 1) then
            (bind ?finalVal "easy")
        elif (eq ?complex 2) then
            (bind ?finalVal "easy or med")
        elif (eq ?complex 3) then
            (bind ?finalVal "easy or med or hard")
        else
            (bind ?finalVal -1)
        )
        (setAppVar "prepComplex" ?finalVal))

    ; A Questionnaire going through the list of all ingredients to ask user about the available ones.
    (defrule askIngredientsQuestions
        (declare (salience 2))
        (fuzzyQuant (quant ?fquant))
        =>
        ; Ingredients questions
        (bind ?result (run-query* customQueries::getAllPosIngredients))
        (while (?result next) do
            (bind ?ingname (?result getString iname))
            (bind ?askquantval (?result getString askquantval))
            (bind ?qtext (str-cat "Is " ?ingname " available? "))
            (bind ?answer (ask-user ?qtext yes-no))
            (if (or (eq ?answer yes) (eq ?answer y)) then
                ; asking quantity available
                (if (eq ?askquantval "y") then
                    (bind ?quantity (ask-user "      Quantity available (few(f)/plenty(p)) " f-p))
                    (if (eq ?quantity p) then
                        (bind ?quantity "plenty")
                    elif (eq ?quantity f) then
                        (bind ?quantity "few")
                    )
                else
                    (bind ?quantity "plenty"))
                (bind ?fquantval (new nrc.fuzzy.FuzzyValue ?fquant ?quantity))
                (addIngredient ?ingname ?answer ?fquantval)
                )))

    ; Time constraint question
    (defrule askTimeConstraintQuestion
        (declare (salience 1))
        =>
        (bind ?answer (ask-user "Any maximum cook time to be set?" yes-no))
        (bind ?maxcooktime -1)
        (if (eq ?answer y) then
            (bind ?answer (ask-user "Maximum cooking duration?" numeric))
            (bind ?maxcooktime ?answer))
        (setAppVar "cookTime" ?maxcooktime))

; Finally, iterating over all the curries which can be made and displaying their details to the user.
(defmodule report)
    (defrule displayResult
        =>
        (bind ?result (run-query* customQueries::getSugCurriesIt))
        (bind ?i 0)
        (printout t crlf "*********************************************")
        (printout t crlf "Curry suggestions")
        (printout t crlf "*********************************************")
        ; Iterating over results
        (while (?result next) do
            (bind ?curryname (?result getString sugCurName))
            (++ ?i)
            (printout t crlf crlf "-----Option " ?i "---" crlf)
            (displayCurryResult ?curryname))
        ; If no curry possible
        (if (eq ?i 0) then
            (printout t crlf "Sorry, but I currently don't have any curry which can be made with the given ingredients")
            (if (eq (getAppVar "cookTime" numeric) -1 ) then
                (printout t ".")
            else
                (printout t " and time contraint." crlf)))
        (printout t crlf "*********************************************" crlf crlf)
        )

