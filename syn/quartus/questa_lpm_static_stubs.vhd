library ieee;
use ieee.std_logic_1164.all;

entity LPM_COUNTER is
    generic (
        LPM_WIDTH        : natural;
        LPM_MODULUS      : natural := 0;
        LPM_DIRECTION    : string  := "UNUSED";
        LPM_AVALUE       : string  := "UNUSED";
        LPM_SVALUE       : string  := "UNUSED";
        LPM_PORT_UPDOWN  : string  := "PORT_CONNECTIVITY";
        LPM_PVALUE       : string  := "UNUSED";
        LPM_TYPE         : string  := "LPM_COUNTER";
        LPM_HINT         : string  := "UNUSED"
    );
    port (
        DATA             : in  std_logic_vector(LPM_WIDTH - 1 downto 0) := (others => '0');
        CLOCK            : in  std_logic;
        CLK_EN           : in  std_logic := '1';
        CNT_EN           : in  std_logic := '1';
        UPDOWN           : in  std_logic := '1';
        SLOAD            : in  std_logic := '0';
        SSET             : in  std_logic := '0';
        SCLR             : in  std_logic := '0';
        ALOAD            : in  std_logic := '0';
        ASET             : in  std_logic := '0';
        ACLR             : in  std_logic := '0';
        CIN              : in  std_logic := '1';
        COUT             : out std_logic := '0';
        Q                : out std_logic_vector(LPM_WIDTH - 1 downto 0);
        EQ               : out std_logic_vector(15 downto 0)
    );
end entity LPM_COUNTER;

architecture qverify_stub of LPM_COUNTER is
begin
    COUT <= '0';
    Q    <= (others => '0');
    EQ   <= (others => '0');
end architecture qverify_stub;

library ieee;
use ieee.std_logic_1164.all;

entity LPM_DIVIDE is
    generic (
        LPM_WIDTHN          : natural;
        LPM_WIDTHD          : natural;
        LPM_NREPRESENTATION : string := "UNSIGNED";
        LPM_DREPRESENTATION : string := "UNSIGNED";
        LPM_PIPELINE        : natural := 0;
        LPM_TYPE            : string := "LPM_DIVIDE";
        LPM_HINT            : string := "LPM_REMAINDERPOSITIVE=TRUE"
    );
    port (
        NUMER               : in  std_logic_vector(LPM_WIDTHN - 1 downto 0);
        DENOM               : in  std_logic_vector(LPM_WIDTHD - 1 downto 0);
        ACLR                : in  std_logic := '0';
        CLOCK               : in  std_logic := '0';
        CLKEN               : in  std_logic := '1';
        QUOTIENT            : out std_logic_vector(LPM_WIDTHN - 1 downto 0);
        REMAIN              : out std_logic_vector(LPM_WIDTHD - 1 downto 0)
    );
end entity LPM_DIVIDE;

architecture qverify_stub of LPM_DIVIDE is
begin
    QUOTIENT <= (others => '0');
    REMAIN   <= (others => '0');
end architecture qverify_stub;
