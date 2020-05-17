functor
import
    Open
export
    textfile:TextFile
    readtweets:ReadTweets

define

    %Calls the FullScan fucntion while opening the first file depending on N
    fun {ReadTweets N}
        {FullScan {New TextFile init(name:"tweets/part_"#N#".txt")} N}
    end

    %Fetches all the tweets in a file in a stream format
    % @pre: - InFile: a TextFile from the file
    %       - N : Determine what files are gonna be worked
    % @post: Returns a stream containing the lines (Line) of all N+4 files.
    fun {FullScan InFile N}
        Line={InFile getS($)}
    in
        if Line==false then
            {InFile close}
            try {FullScan {New TextFile init(name:"tweets/part_"#N+4#".txt")} N+4}
            catch ErrorDirectory then nil
            end
        else
            Line|{FullScan InFile N}
        end
    end

    class TextFile % This class enables line-by-line reading
        from Open.file Open.text
    end

end