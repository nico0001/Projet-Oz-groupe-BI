functor
import
    Open
export
    textfile:TextFile
    scan:Scan
    fullscan:FullScan

define
    % Fetches the N-th line in a file
    % @pre: - InFile: a TextFile from the file
    %       - N: the desires Nth line
    % @post: Returns the N-the line or 'none' in case it doesn't exist
    
    fun {Scan InFile N}
        Line={InFile getS($)}
    in
        if Line==false then
            {InFile close}
            none
        else
            if N==1 then
                {InFile close}
                Line
            else
                {Scan InFile N-1}
            end
        end
    end

    %Fetches all the line in a file
    % @pre: - InFile: a TextFile from the file
    % @post: Returns a stream containing the lines : Line1|Line2|...|Line100|nil
    fun {FullScan InFile}
        Line={InFile getS($)}
    in
        if Line==false then
            {InFile close}
            nil
        else
            Line|{FullScan InFile}
        end
    end

    class TextFile % This class enables line-by-line reading
        from Open.file Open.text
    end

end