functor
import 
    System
    Browser
export
tweetstoword:TweetsToWord
wordlink:WordLink
wordlink2:WordLink2
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
            if Word==nil then %Si le mot==nil à cause de plusieurs espaces (32) on ne retourne pas le mot.
                {TweetToListOfWord OtherWords}
            else
                Word|{TweetToListOfWord OtherWords}
            end
        end
    end

    %Fetches all the words and his next word
    % @pre: - StreamWords: a stream of stream of words
    %       - P : Key port access to the stream
    % @post: Send to a stream tuples of the word and his next word
    proc {WordLink StreamWords P}
        case StreamWords
        of nil then skip
        [] H|T then
            {WordLinkTweet H P}
            {WordLink T P}
        end
    end

    %Fetches all the words and his next word
    % @pre: - Words: a stream of words
    %       - P : Key port access to the stream
    % @post: Send to a stream tuples of the word and his next word
    proc {WordLinkTweet Words P}
        case Words
        of H|T then
            if T==nil then
                skip
            else 
                {Port.send P H#T.1}
                {WordLinkTweet T P}
            end
        end
    end

    proc {WordLink2 StreamWords P}
        case StreamWords
        of nil then skip
        [] H|T then
            {WordLinkTweet2 H P}
            {WordLink2 T P}
        end
    end

    proc {WordLinkTweet2 Words P}
        case Words
        of H|T then
            if T==nil then
                skip
            else if T.2==nil then
                    skip
                else
                    {Browse {VirtualString.toString H#T.1}#T.2.1}
                    {Port.send P {VirtualString.toString H#T.1}#T.2.1}
                    {WordLinkTweet2 T P}
                end
            end
        end
    end

end