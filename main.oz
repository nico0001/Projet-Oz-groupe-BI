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
    DicFreq = Dict.dicfreq
    FinalDictionary = Dict.finaldictionary
    StA = String.toAtom

%%% Threads
    local Lines1 Lines2 Words1 Words2 P S1 DDFreq Kamel Wali X1 X2 in
        %Read
        thread Lines1 = {FullScanCall 1} end
        thread Lines2 = {FullScanCall 2} end
        %Parsing
        thread Words1 = {TweetsToWord Lines1} end
        thread Words2 = {TweetsToWord Lines2} end
        P = {Port.new S1}
        
        thread {WordLink Words1 P} Wali=1 end
        thread {WordLink Words2 P} Kamel=Wali end
        {Wait Kamel} 
        {Port.send P nil}
        DDFreq = {Dictionary.new}
        thread {DicFreq DDFreq S1} X1=1 end
        %{Show {Dictionary.entries DDFreq}}
        DFinal = {Dictionary.new}
        {Wait X1}
        thread {FinalDictionary DFinal DDFreq {Dictionary.keys DDFreq}} X2=1 end
        {Wait X2}
        %{Browse {Dictionary.entries DFinal}}
    end

    fun{Find W}
        {Dictionary.condGet DFinal {StA W} {StA "Fristi"}}
    end


%%% GUI
    % Make the window description, all the parameters are explained here:
    % http://mozart2.org/mozart-v1/doc-1.4.0/mozart-stdlib/wp/qtk/html/node7.html)
    Text1 Text2 Description=td(
        title: "Automatic input 1 gram"
        lr(
            text(handle:Text1 width:28 height:5 background:white foreground:black wrap:word)
            button(text:"Change" action:Press)
        )
        text(handle:Text2 width:28 height:5 background:black foreground:white glue:w wrap:word)
        action:proc{$}{Application.exit 0} end % quit app gracefully on window closing
    )
    
    proc {Press} Inserted Word Line in
        Inserted = {Text1 getText(p(1 0) 'end' $)} % example using coordinates to get text
        Word = {Find {List.subtract {List.last {String.tokens Inserted 32}} 10}}
        Line = {VirtualString.toString {List.subtract Inserted 10}#" "#Word}
        {Text2 set(1:(Line))} % you can get/set text this way too
    end
    % Build the layout from the description
    W={QTk.build Description}
    {W show}

    %{Text1 tk(insert 'end' {GetLine "tweets/part_1.txt" 1})}
    {Text1 bind(event:"<Control-s>" action:Press)} % You can also bind events
end
