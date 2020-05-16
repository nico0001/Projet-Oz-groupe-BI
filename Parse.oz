functor
import 
    System
    Browser
export
tweetstoword:TweetsToWord
wordlink:WordLink
define
    BrowserObject = {New Browser.'class' init}
    {BrowserObject option(buffer size:1000)} %Changer la taille du buffer
    {BrowserObject option(representation strings:true)} %Affiche les strings
    Browse = proc {$ X} {BrowserObject browse(X)} end

    %Fetches all the words off the tweets in a stream format
    % @pre: - SFileLines: a stream of tweets in a string format
    % @post: Returns a stream containing the words 
    fun {TweetsToWord FileLines}
        case FileLines
        of nil then nil
        [] H|T then
            %if {List.member "\r" H} then
            %    {TweetToListOfWord H}|{TweetsToWord T}
            %else
            %    %Append a "\r" to separate tweets
            %    {TweetToListOfWord {List.append H "\r"}}|{TweetsToWord T}
            %end
            {TweetToListOfWord H}|{TweetsToWord T}
        end
    end

    %Fetches all the words in a string in a stream format
    % @pre: - Words: a tweet in a string format
    % @post: Returns a stream containing the words of the tweet
    fun {TweetToListOfWord Words}
        if Words == nil then 
            nil
        else Word OtherWords in
            {String.token Words 32 Word OtherWords}
            Word|{TweetToListOfWord OtherWords}
        end
    end

    proc {WordLink StreamWords P}
        case StreamWords
        of nil then skip
        [] H|T then
            {WordLinkTweet H P}
            {WordLink T P}
        else
            {System.show '@@@@@@@@@@@@@@@@@@@@@@@@@@@@'}
            {System.show StreamWords}
        end
    end

    proc {WordLinkTweet Words P}
        case Words
        of H|T then
            if T==nil then
                skip
            else if T.1==nil then %Si le mot==nil à cause de plusieurs espaces (32) on passe.
                {WordLinkTweet T.2 P}
                else
                    %{Browse Words}
                    %{Browse H#T.1}
                    {Port.send P H#T.1}
                    {WordLinkTweet T P}
                end
            end
        [] nil then
            skip
        end
    end

end