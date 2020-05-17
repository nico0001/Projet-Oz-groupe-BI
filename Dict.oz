functor
export
    dicfreq:DicFreq
    finaldictionary:FinalDictionary
    findnext:FindNext

define
    StA = String.toAtom

    % @pre: - D: a empty dictionary
    %       - Words: Stream of tuples of a word(s) and his/their next one
    % @post: D has all the words as keys and has a dictionary (DNext) for each word as
    %        value containing as keys next possible words with their frequency as value.
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
                else
                    {Dictionary.put DNext {StA H.2} {Dictionary.condGet DNext {StA H.2} 0}+1}
                end
                {DicFreq D T}
            end
        end
    end

    %Organize the call of FindMaxFreq by word
    % @pre: -D: the dictionary of dictionaries of frequency
    %       -LstWord: List of all the words
    % @post: D has now all the words as keys and his/their next one as value
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

    %Finds the word with the biggest frequency
    % @pre: -D: the dictionary of dictionaries of frequency
    %       -Word: the word(s) for whom we are finding his/their best next one
    %       -DNext: the dictionary of frequency
    %       -NextWords: Possible words to treat
    %       -Max: Tuple Word#frequency initialized to none#0
    % @post: D has now the best next word as value for the key Word
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