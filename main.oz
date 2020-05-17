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
    FullScanCall = Reader.fullscancall
    TweetsToWord = Parse.tweetstoword
    WordLink = Parse.wordlink
    WordLink2 = Parse.wordlink2
    DicFreq = Dict.dicfreq
    FinalDictionary = Dict.finaldictionary
    StA = String.toAtom

%%% Threads
    local Lines1 L2 L3 L4 Words1 W2 W3 W4 P1 P2 S1 S2 A1 A2 A3 A4 X1 X2 in
        %Read
        thread Lines1 = {FullScanCall 1} end
        thread L2 = {FullScanCall 2} end
        thread L3 = {FullScanCall 3} end
        thread L4 = {FullScanCall 4} end
        %Parsing1
        thread Words1 = {TweetsToWord Lines1} end
        thread W2 = {TweetsToWord L2} end
        thread W3 = {TweetsToWord L3} end
        thread W4 = {TweetsToWord L4} end
        P1 = {Port.new S1}
        P2 = {Port.new S2}

        %Parsing2  1-gram      
        thread {WordLink Words1 P1} A1=1 end
        thread {WordLink W2 P1} A2=A1 end
        thread {WordLink W3 P1} A3=A2 end
        thread {WordLink W4 P1} A4=A3 end
        %Parsing2  2-gram
        %thread {WordLink2 Words1 P2} Jean=1 end
        %thread {WordLink2 W2 P2} Jean=1 end
        %thread {WordLink2 W3 P2} Jean=1 end
        %thread {WordLink2 W4 P2} Jean=1 end
        {Wait A4}
        {Port.send P1 nil}
        {Port.send P2 nil}
        D1 = {Dictionary.new}
        D2 = {Dictionary.new}
        thread {DicFreq D1 S1} {FinalDictionary D1 {Dictionary.keys D1}} X1=1 end
        thread {DicFreq D2 S2} {FinalDictionary D2 {Dictionary.keys D2}} X1=1 end
        {Wait X1}
    end

    fun{Find W}
        {Dictionary.condGet D1 {StA W} {StA "Aucun résultat"}}
    end


%%% GUI
    % Make the window description, all the parameters are explained here:
    % http://mozart2.org/mozart-v1/doc-1.4.0/mozart-stdlib/wp/qtk/html/node7.html)
    Text1 Text2 Description=td(
        title: "Automatic input 1 gram"
        lr(
            text(handle:Text1 width:56 height:10 background:white foreground:black wrap:word)
            button(text:"Propose" action:Press)
            button(text:"Next word" action:Replace)
        )
        text(handle:Text2 width:56 height:5 background:black foreground:white glue:w wrap:word)
        action:proc{$}{Application.exit 0} end % quit app gracefully on window closing
    )
    
    proc {Press} Inserted NextWord Line in
        Inserted = {Text1 getText(p(1 0) 'end' $)} % example using coordinates to get text
        NextWord = {Find {List.subtract {List.last {String.tokens Inserted 32}} 10}}
        Line = {VirtualString.toString NextWord}
        {Text2 set(1:(Line))} % you can get/set text this way too
    end
    proc {Replace} Inserted NextWord in
        Inserted = {List.subtract {Text1 getText(p(1 0) 'end' $)} 10}
        NextWord = {List.subtract {Text2 getText(p(1 0) 'end' $)} 10}
        {Text1 set(1:{VirtualString.toString Inserted#" "#NextWord})}
        {Press}
    end
    % Build the layout from the description
    W={QTk.build Description}
    {W show}

    %{Text1 tk(insert 'end' {GetLine "tweets/part_1.txt" 1})}
    {Text1 bind(event:"<Control-s>" action:Press)} % You can also bind events
end
