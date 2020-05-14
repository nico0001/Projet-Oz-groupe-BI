functor

export
linestoword:LinesToWord
define

    %Fetches all the words in a string in a stream format
    % @pre: - Words: a tweet in a string format
    % @post: Returns a stream containing the words of the tweet
        if Words == nil then 
            if {List.member 13 Words} then
                none
            else
                %Append a "\r" to separate tweets
                {Append Words 13}
            end
        else Word OtherWords in
            {String.token Words 32 Word OtherWords}
            Word|{LineToListWord OtherWords}
        end
    end

    %Fetches all the words off the tweets in a stream format
    % @pre: - StreamFileLines: a stream of tweets in a string format
    % @post: Returns a stream containing the words 
    fun {LinesToWord StreamFileLines}
        case StreamFileLines
        of nil then nil
        [] H|T then
            {LineToListWord H}|{LinesToWord T}
        end
    end


end