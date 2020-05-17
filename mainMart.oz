functor
import
    QTk at 'x-oz://system/wp/QTk.ozf'
    System
    Application
    %OS
    Browser
    Open

define
%%% Easier macros for imported functions

    %Browse = Browser.browse
    BrowserObject = {New Browser.'class' init}
    {BrowserObject option(buffer size:1000)} %Changer la taille du buffer
    {BrowserObject option(representation strings:true)} %Affiche les strings
    Browse = proc {$ X} {BrowserObject browse(X)} end
    Show = System.show
    StA = String.toAtom
    VStS = VirtualString.toString
    Subtract = List.subtract
    Put = Dictionary.put
    CondGet = Dictionary.condGet


%%% Read File

    % This class enables line-by-line reading
    class TextFile
        from Open.file Open.text
    end


    % Read Recursively a file from a certain point until the end
    % @pre: - FILE_NAME: a TextFile from the file
    %       - A: the first line to be read in the file (A = 1 will read all the lines)
    % @post: Returns a List of all the char (in ASCII) from the wanted end-portion of the file
    fun {FullScan1 File N}
        Line = {File getS($)} in
        if Line == false then
            {File close}
            try {FullScan1 {New TextFile init(name:"tweets/part_"#N+4#".txt")} N+4}
            catch E then nil
            end
        else
            {Append Line "\r"}|{FullScan1 File N}    % Make all lines finsih with a '\r' to mark the end of a tweet
        end
    end

    % Read all the ODD or EVEN files.
    % @pre: - N: Select the parity of files read: 1:ODD, 2:EVEN
    % @post: Returns a stream of all the tweets of Donald Trump...
    fun {FullScan N}
        {FullScan1 {New TextFile init(name:"tweets/part_"#N#".txt")} N}
    end
    

%%% Parse functions

    % Dynamically create a flatten stream from another.
    % @pre: - Current: 1st element of the stream to flatten
    %       - Next: 2nd element of the stream to flatten (rest of the Stream) 
    % @post: Returns a flattened stream, a list without nested lists.
    fun {Flat Current Next}
        case Current of nil then
            case Next of nil then nil
            [] H|T then {Flat H T} end
        else
            local L1 L2 in
                {String.token Current 32 L1 L2}
                L1|{Flat L2 Next}
            end
        end
    end


    % Create a tuple list with every occurence of (Last Word#Next Word) (1-GRAM) in a words list.
    % @pre: - L: The word list to be analysed
    %       - P: The port to the stream where to send the tuples
    % @post: The stream associated with the port P contains all the tuples obtainable from the list L.
    proc{Parse1 L P}
        if L.2 == nil then skip
        else
            if {List.member 13 L.1} then
                {Parse1 L.2 P}
            else
                {Port.send P L.1#{Subtract L.2.1 13}}
                {Parse1 L.2 P}
            end
        end
    end


    % Create a tuple list with every occurence of ((2 Last Words)#Next Word) (2-GRAM) in a words list.
    % @pre: - L: The word list to be analysed
    %       - P: The port to the stream where to send the tuples
    % @post: The stream associated with the port P contains all the tuples obtainable from the list L.
    proc{Parse2 L P}
        if L.2.2 == nil then skip
        else
            if {List.member 13 L.2.1} then
                    {Parse2 L.2.2 P}
            else
                {Port.send P {VStS L.1#L.2.1}#{Subtract L.2.2.1 13}}
                {Parse2 L.2 P}
            end
        end
    end


%%% Create Dictionaries

    % Create a Frequency Dictionary.
    % @pre: - L: List of (keys:items) to be analysed
    %       - D: Frequency Dictionary 
    % @post: Dictionary D is Full.
    proc {MakeInventory L D}    % L:List  D:Dictionary  N:Ngram
        case L of H|T then
            if H == nil then skip
            else
                local Key Count in
                    Key = {CondGet D {StA H.1} 0}
                    if Key == 0 then    %First time a word appears
                        {Put D {StA H.1} {Dictionary.new}}
                        {Put {Dictionary.get D {StA H.1}} {StA H.2} 1}
                    else
                        Count = {CondGet Key {StA H.2} 0}
                        {Put Key {StA H.2} Count+1}    % Add 1 to the occurence of a couple   
                    end
                end
                {MakeInventory T D}
            end
        end
    end


    % Read a Frequency Dictionary and find for each key (Word) the most frequent item (Next word).
    % @pre: - Din: Frequency Dictionary
    %       - Dout: Dictionary (Word: Most frequent next word) 
    % @post: Fill Dout
    proc {WhatsNext D}
        Max Key in  % Key Word MaxValue
        Key = {Cell.new 0}
        Max = {Cell.new 0}
        for K in {Dictionary.entries D} do
            {Cell.assign Max 0}
            for W in {Dictionary.entries K.2} do
                if W.2>{Cell.access Max} then
                    {Cell.assign Key W.1}
                    {Cell.assign Max W.2}
                end
            end
            {Put D K.1 {Cell.access Key}}
        end
    end
        

%%% Threads

    local TS1 TS2 TS3 TS4 TF1 TF2 TF3 TF4 P1 P2 S1 S2 X1 X2 X3 X4 X5 X6 X7 X8 XD1 XD2 in
        %Scan
        thread TS1 = {FullScan 1} end
        thread TS2 = {FullScan 2} end
        thread TS3 = {FullScan 3} end
        thread TS4 = {FullScan 4} end

        %Flatten
        thread TF1 = {Flat TS1.1 TS1.2} end
        thread TF2 = {Flat TS2.1 TS2.2} end
        thread TF3 = {Flat TS3.1 TS3.2} end
        thread TF4 = {Flat TS4.1 TS4.2} end

        %Port
        P1 = {Port.new S1}  %1-Gram
        P2 = {Port.new S2}  %2-Gram

        %Parse 1-Gram
        thread {Parse1 TF1 P1} X1=1 end
        thread {Parse1 TF2 P1} X2=X1 end
        thread {Parse1 TF3 P1} X3=X2 end
        thread {Parse1 TF4 P1} X4=X3 {Port.send P1 nil} end

        %Parse 2-Gram
        thread {Parse2 TF1 P2} X5=1 end
        thread {Parse2 TF2 P2} X6=X5 end
        thread {Parse2 TF3 P2} X7=X6 end
        thread {Parse2 TF4 P2} X8=X7 {Port.send P2 nil} end

        %Creat Frequency Dictionarys
        Dico1 = {Dictionary.new}
        Dico2 = {Dictionary.new}
        thread {MakeInventory S1 Dico1} {WhatsNext Dico1} XD1=1 end   %1-Gram Frequency Dictionary
        thread {MakeInventory S2 Dico2} {WhatsNext Dico2} XD2=XD1 end   %2-Gram Frequency Dictionary        

        %Create Next Word Dictionaries
        {Wait XD2}
    end


%%% Prediction

    %Determines the Next Word based on the 2 last one.
    %Search first in the 2-Gram Dictionary, then in the 1-Gram if nothing was found.
    % @pre: - Din: Frequency Dictionary
    %       - Dout: Dictionary (Word: Most frequent next word) 
    % @post: Fill Dout
    fun {NextWord W1 W2}
        {CondGet Dico2 {StA {VStS W1#W2}} {CondGet Dico1 {StA W2} "OZ"}}
    end


%%% GUI
    % Make the window description, all the parameters are explained here:
    % http://mozart2.org/mozart-v1/doc-1.4.0/mozart-stdlib/wp/qtk/html/node7.html)
    Text1 Text2 Description=td(
        title: "Frequency count"
        lr(
            text(handle:Text1 width:88 height:20 background:white foreground:black wrap:word)
            button(text:"Propose" action:Propose)
            button(text:"Replace" action:Replace)
        )
        text(handle:Text2 width:88 height:5 background:black foreground:white glue:w wrap:word)
        action:proc{$}{Application.exit 0} end % quit app gracefully on window closing
    )

    % Propose the next word to be put based on the last two words
    proc {Propose} Original Inserted Size PreLastWord LastWord Word in
        Original = {Text1 getText(p(1 0) 'end' $)}
        Inserted = {String.tokens Original 32}
        Size = {List.length Inserted}
        if Size == 0 then
            LastWord = "OZ"
            PreLastWord = "OZ"
        else
            if Size == 1 then
                LastWord = {Subtract Inserted.1 10}
                PreLastWord = "OZ"
            else
                LastWord = {Subtract {List.last Inserted} 10}
                PreLastWord = {Subtract {List.drop Inserted Size-2}.1 32}
            end
        end
        Word = {NextWord PreLastWord LastWord}
        {Text2 set(1:{VStS Word})} % you can get/set text this way too
    end

    proc {Replace} Inserted NewWord in
        Inserted = {Subtract {Text1 getText(p(1 0) 'end' $)} 10}
        NewWord = {Subtract {Text2 getText(p(1 0) 'end' $)} 10}
        {Text1 set(1:{VStS Inserted#" "#NewWord})}
        {Propose}
    end

    % Build the layout from the description
    W={QTk.build Description}
    {W show}

    {Text1 tk(insert 'end' "MAKE AMERICA")}
    {Text2 tk(insert 'end' "GREAT")}
    {Text1 bind(event:"<Control-s>" action:Propose)} % You can also bind events

    {Show 'You can print in the terminal...'}
    {Browse '... or use the browser window'}
end