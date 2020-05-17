functor

import
    Browser
    System
export
    dicfreq:DicFreq
    finaldictionary:FinalDictionary
define
    BrowserObject = {New Browser.'class' init}
    {BrowserObject option(buffer size:1000)} %Changer la taille du buffer
    {BrowserObject option(representation strings:true)} %Affiche les strings
    Browse = proc {$ X} {BrowserObject browse(X)} end
    StA = String.toAtom
%%% Création dictionary
    proc {DicFreq D Words}
        case Words
        of H|T then DNext in
            if H==nil then
                skip
            else
                DNext = {Dictionary.condGet D {StA H.1} {Dictionary.new}}
                if {Dictionary.isEmpty DNext} then %Si le mot n'est pas encore dans le dictionnaire
                    {Dictionary.put D {StA H.1} DNext}
                    {Dictionary.put DNext {StA H.2} 1}
                    %{Browse {Dictionary.keys D}}
                else
                    {Dictionary.put DNext {StA H.2} {Dictionary.condGet DNext {StA H.2} 0}+1}
                    %{Browser.browse {Dictionary.keys D}}
                    %{Browse {Dictionary.entries {Dictionary.condGet D {StA "a"} {Dictionary.new}}}}
                end
                {DicFreq D T}
            end
        end
    end

    proc {FinalDictionary D LstWord}
        case LstWord
        of nil then skip
        [] Word|T then DNext NextWords in
            {Dictionary.get D Word DNext}
            {Dictionary.keys DNext NextWords}
            {FindMaxFreq D Word DNext NextWords {Cell.new none#0}}
            {FinalDictionary D T}
        end
    end

    proc {FindMaxFreq D Word DNext NextWords Max}
        case NextWords
        of nil then {Dictionary.put D Word {Cell.access Max}.1}
        [] H|T then Freq in
            Freq = {Dictionary.get DNext H}
            if Freq>{Cell.access Max}.2 then
                {Cell.assign Max H#Freq}
            end
        {FindMaxFreq D Word DNext T Max}
        end
    end

end