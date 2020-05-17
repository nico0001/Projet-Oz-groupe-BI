functor
import
    QTk at 'x-oz://system/wp/QTk.ozf'
    System
    Application
    OS
    Browser
    Reader
    Parse
    Dict

define
%%% Easier macros for imported functions
    %Browse = Browser.browse
    BrowserObject = {New Browser.'class' init}
    {BrowserObject option(buffer size:1000)} %Changer la taille du buffer
    {BrowserObject option(representation strings:true)} %Affiche les strings
    Browse = proc {$ X} {BrowserObject browse(X)} end
    Show = System.show
    ReadTweets = Reader.readtweets
    ParseTweets = Parse.parsetweets
    WordsLink = Parse.wordslink
    DicFreq = Dict.dicfreq
    FinalDictionary = Dict.finaldictionary
    StA = String.toAtom
    VStS = VirtualString.toString

%%% Threads
    local Lines1 L2 L3 L4 Words1 W2 W3 W4 P1 P2 S1 S2 A1 A2 A3 A4 X1 X2 in
        %Read
        thread Lines1 = {ReadTweets 1} end
        thread L2 = {ReadTweets 2} end
        thread L3 = {ReadTweets 3} end
        thread L4 = {ReadTweets 4} end
        %Parsing1
        thread Words1 = {ParseTweets Lines1} end
        thread W2 = {ParseTweets L2} end
        thread W3 = {ParseTweets L3} end
        thread W4 = {ParseTweets L4} end
        
        P1 = {Port.new S1} %Port du 1-gram
        P2 = {Port.new S2} %Port du 2-gram
        %Parsing2      
        thread {WordsLink Words1 P1 P2} A1=1 end
        thread {WordsLink W2 P1 P2} A2=A1 end
        thread {WordsLink W3 P1 P2} A3=A2 end
        thread {WordsLink W4 P1 P2} A4=A3 end
        {Wait A4}

        {Port.send P1 nil}
        {Port.send P2 nil}

        %Making of the dictionaires
        D1 = {Dictionary.new} %1-gram
        D2 = {Dictionary.new} %2-gram
        thread {DicFreq D1 S1} {FinalDictionary D1 {Dictionary.keys D1}} X1=1 end
        thread {DicFreq D2 S2} {FinalDictionary D2 {Dictionary.keys D2}} X2=X1 end
        {Wait X2}
    end


    %Return the next word depending on the 2 last words
    % @pre: -W1: the last word written
    %       -W2: the one before the last
    % @post: Return the next word or "Aucune proposition" 
    fun{FindNext W1 W2}
        {Dictionary.condGet D2 {StA {VStS W2#W1}}
        {Dictionary.condGet D1 {StA W1} {StA "Aucune proposition"}}}
    end


%%% GUI
    % Make the window description, all the parameters are explained here:
    % http://mozart2.org/mozart-v1/doc-1.4.0/mozart-stdlib/wp/qtk/html/node7.html)
    Text1 Text2 Description=td(
        title: "Saisie automatique 2-gram et 1-gram"
        lr(
            text(handle:Text1 width:56 height:10 background:white foreground:black wrap:word)
            button(text:"Propose" action:Suggest)
            button(text:"Write next word" action:Write)
        )
        text(handle:Text2 width:56 height:5 background:black foreground:white glue:w wrap:word)
        action:proc{$}{Application.exit 0} end % quit app gracefully on window closing
    )
    
    %Suggests a word depending on what the user writes
    proc {Suggest} Inserted NextWord ReversedI ILen Line in
        Inserted = {List.subtract {Text1 getText(p(1 0) 'end' $)} 10}
                
        if Inserted==nil then %If the user didn't write anything
            Line = "Veuillez taper un mot svp c'est plus gentil"
        else
            ReversedI = {List.reverse {String.tokens Inserted 32}}
            {List.length ReversedI ILen}
            if ILen==1 then %If the user only write one word
                NextWord = {FindNext {List.nth ReversedI 1} "Je n'existe pas"}
            else
                NextWord = {FindNext {List.nth ReversedI 1} {List.nth ReversedI 2}}
            end
            Line = {VStS NextWord}
        end
        {Text2 set(1:(Line))}
    end

    %Writes the next word if there is one
    proc {Write} Inserted NextWord in
        Inserted = {List.subtract {Text1 getText(p(1 0) 'end' $)} 10}
        NextWord = {List.subtract {Text2 getText(p(1 0) 'end' $)} 10}
        if NextWord=="Veuillez taper un mot svp c'est plus gentil" then
            skip
        else if NextWord=="Aucune proposition" then
                skip
            else
                {Text1 set(1:{VStS Inserted#" "#NextWord})}
                {Suggest}
            end
        end
    end
    % Build the layout from the description
    W={QTk.build Description}
    {W show}

    %{Text1 tk(insert 'end' {GetLine "tweets/part_1.txt" 1})}
    {Text1 bind(event:"<Control-s>" action:Suggest)} % You can also bind events
end
