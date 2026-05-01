library ieee;
use ieee.std_logic_1164.all;

entity LPM_DIVIDE is
    generic(
        LPM_WIDTHN          : natural;
        LPM_WIDTHD          : natural;
        LPM_NREPRESENTATION : string := "UNSIGNED";
        LPM_DREPRESENTATION : string := "UNSIGNED";
        LPM_PIPELINE        : natural := 0;
        LPM_TYPE            : string := "LPM_DIVIDE";
        LPM_HINT            : string := "LPM_REMAINDERPOSITIVE=TRUE"
    );
    port(
        NUMER    : in  std_logic_vector(LPM_WIDTHN - 1 downto 0);
        DENOM    : in  std_logic_vector(LPM_WIDTHD - 1 downto 0);
        ACLR     : in  std_logic := '0';
        CLOCK    : in  std_logic := '0';
        CLKEN    : in  std_logic := '1';
        QUOTIENT : out std_logic_vector(LPM_WIDTHN - 1 downto 0);
        REMAIN   : out std_logic_vector(LPM_WIDTHD - 1 downto 0)
    );
end entity LPM_DIVIDE;

architecture blackbox of LPM_DIVIDE is
    attribute black_box : boolean;
    attribute black_box of blackbox : architecture is true;
begin
end architecture blackbox;
