functor
import
    Open
export
    textfile:TextFile
    fullscancall:FullScanCall

define

    fun {FullScanCall N}
        {FullScan {New TextFile init(name:"tweets/part_"#N#".txt")} N}
    end

    %Fetches all the line in a file in a stream format
    % @pre: - InFile: a TextFile from the file
    %       - N : Determine what files are gonna be worked
    % @post: Returns a stream containing the lines of all N+2 files, if N = 1 : Line1|Line3|...|Line99|nil
    fun {FullScan InFile N}
        Line={InFile getS($)}
    in
        if Line==false then
            {InFile close}
            try {FullScan {New TextFile init(name:"tweets/part_"#N+2#".txt")} N+2}
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