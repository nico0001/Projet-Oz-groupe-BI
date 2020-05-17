functor
export
    parsetweets:ParseTweets
    wordslink:WordsLink

define

    %Organize the call of TweetToListOfWord by tweet
    % @pre: - FileLines: a stream of tweets in a string format
    % @post: Returns a stream of streams containing the words of one tweet
    fun {ParseTweets FileLines}
        case FileLines
        of nil then nil
        [] H|T then
            {TweetToListOfWord H}|{ParseTweets T}
        end
    end

    %Parses all the words of one tweet
    % @pre: - Words: a tweet/line in a string format
    % @post: Returns a stream containing the words of the tweet/line
    fun {TweetToListOfWord Words}
        if Words == nil then 
            nil
        else Word OtherWords in
            {String.token Words 32 Word OtherWords}
            if Word==nil then %Si le mot==nil à cause de plusieurs espaces (32) on ne retourne pas le mot.
                {TweetToListOfWord OtherWords}
            else
                {List.substract Word {String.toAtom "#"}}
                {Browser.browse Word}
                Word|{TweetToListOfWord OtherWords}
            end
        end
    end

    %Organize the call of WordLinkTweet by tweet
    % @pre: - StreamWords: a stream of stream of words of one tweet
    %       - P1 : Key port access to a stream S1
    %       - P2 : Key port access to a stream S2
    % @post: Send to the streams S1 and S2 tuples of the word(s) and his/their next word for all tweets
    proc {WordsLink StreamWords P1 P2}
        case StreamWords
        of nil then skip
        [] H|T then
            {WordsLinkTweet H P1 P2}
            {WordsLink T P1 P2}
        end
    end

    %Sends to a stream the words and his next word of one tweet
    % @pre: - Words: a stream of words of one tweet
    %       - P1 : Key port access to a stream S1
    %       - P2 : Key port access to a stream S2
    % @post: Send to the streams S1 and S2 tuples of the word(s) and his next word for one tweet
    proc {WordsLinkTweet Words P1 P2}
        case Words
        of H|T then
            if T==nil then
                skip
            else 
                {Port.send P1 H#T.1} %1-gram
                if T.2==nil then skip
                else 
                    {Port.send P2 {VirtualString.toString H#T.1}#T.2.1} %2-gram
                end
                {WordsLinkTweet T P1 P2}
            end
        end
    end

end