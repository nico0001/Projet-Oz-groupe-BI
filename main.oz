functor
import
    QTk at 'x-oz://system/wp/QTk.ozf'
    System
    Application
    OS
    Browser
    Reader
    Parse
define
%%% Easier macros for imported functions
    %Browse = Browser.browse
    BrowserObject = {New Browser.'class' init}
    {BrowserObject option(buffer size:1000)} %Changer la taille du buffer
    {BrowserObject option(representation strings:true)} %Affiche les strings
    {BrowserObject option(representation strings:true)}
    Browse = proc {$ X} {BrowserObject browse(X)} end
    Show = System.show
    FullScan = Reader.fullscan
    LinesToWord = Parse.linestoword

%%% Création dictionary
    local Dic K V in
        Dic = {Dictionary.new}
        K = "bonjour"
        V = "Jésus"
        {Dictionary.put Dic {String.toAtom K} {String.toAtom V}}
        {Browse {Dictionary.get Dic {String.toAtom K}}}
    end

%%% Threads
    %Read
    local S1 S2 W1 W2 in
    thread S1 = {FullScan {New Reader.textfile init(name:"tweets/part_1.txt")} 1} end
    thread S2 = {FullScan {New Reader.textfile init(name:"tweets/part_2.txt")} 2} end
    %{Browse S1|S2}
    %{Browse S2}
    %Parse
    thread W1 = {LinesToWord S1} end
    thread W2 = {LinesToWord S2} end
    %thread {ForAll S2 LineToWord} end
    %{Browse W1}
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
