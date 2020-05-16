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
        of nil then skip
        [] H|T then DNext in
            DNext = {Dictionary.condGet D {StA H.1} {Dictionary.new}}
            {Dictionary.put DNext {StA H.2} {Dictionary.condGet DNext {StA H.2} 0}+1}
            {Dictionary.put D {StA H.1} DNext}
            {Browser.browse {Dictionary.keys D}}
            %{System.show {Dictionary.entries {Dictionary.condGet D {StA "a"} {Dictionary.new}}}}
            {DicFreq D T}
        end
    end

    proc {FinalDictionary DFinal DFreq LstWord}
        case LstWord
        of nil then skip
        [] Word|T then DNext NextWords in
            {Dictionary.get DFreq Word DNext}
            {Dictionary.keys DNext NextWords}
            {FindMaxFreq DFinal Word DNext NextWords 0#0}
            {FinalDictionary DFinal DFreq T}
        end
    end

    proc {FindMaxFreq DFinal Word DNext NextWords Max}
        case NextWords
        of nil then {Dictionary.put DFinal Word Max.1}
        [] H|T then Freq in
            Freq = {Dictionary.get DNext H}
            if Freq>Max.2 then
                Max=H#Freq
                {FindMaxFreq DFinal Word DNext T Max}
            else
                {FindMaxFreq DFinal Word DNext T Max}
            end
        end
    end

end