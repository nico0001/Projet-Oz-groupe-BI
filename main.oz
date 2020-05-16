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

%%% Threads
    local Lines1 Lines2 Words1 Words2 P S1 DDFreq DFinal X X1 X2 in
    %Read
    thread Lines1 = {FullScanCall 1} end
    thread Lines2 = {FullScanCall 2} end
    %{Browse Lines1|Lines2}
    %{Browse Lines1}
    %Parsing
    thread Words1 = {TweetsToWord Lines1} end
    thread Words2 = {TweetsToWord Lines2} end
    %{Browse Words1|Words2}
    %{Browse Words1}
    P = {Port.new S1}
    thread {WordLink Words1 P} end
    thread {WordLink Words2 P} end
    %{Browse S1}
    DDFreq = {Dictionary.new}
    thread {DicFreq DDFreq S1} X=1 end
    {Wait X}
    DFinal = {Dictionary.new}
    {FinalDictionary DFinal DDFreq {Dictionary.keys DDFreq}}
    {Browse {Dictionary.entries DFinal}}
    end


%%% GUI
    % Make the window description, all the parameters are explained here:
    % http://mozart2.org/mozart-v1/doc-1.4.0/mozart-stdlib/wp/qtk/html/node7.html)
    Text1 Text2 Description=td(
        title: "Frequency count"
        lr(
            text(handle:Text1 width:28 height:5 background:white foreground:black wrap:word)
            button(text:"Change" action:Press)
        )
        text(handle:Text2 width:28 height:5 background:black foreground:white glue:w wrap:word)
        action:proc{$}{Application.exit 0} end % quit app gracefully on window closing
    )
    proc {Press} Inserted in
        Inserted = {Text1 getText(p(1 0) 'end' $)} % example using coordinates to get text
        {Text2 set(1:Inserted)} % you can get/set text this way too
    end
    % Build the layout from the description
    W={QTk.build Description}
    {W show}

    %{Text1 tk(insert 'end' {GetLine "tweets/part_1.txt" 1})}
    {Text1 bind(event:"<Control-s>" action:Press)} % You can also bind events

end
