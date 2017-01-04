
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity system is
    Port ( sw : in STD_LOGIC_VECTOR (7 downto 0);
           led : out STD_LOGIC_VECTOR (7 downto 0);
           an, doorL, doorR : out STD_LOGIC_VECTOR (3 downto 0);
           seg : out STD_LOGIC_VECTOR (6 downto 0);
           clk,reset, upButton,downButton : in STD_LOGIC);
end system;

architecture Behavioral of system is
type state is (kat0,kat1,kat2,kat3,kat4,kat5,kat6,kat7);
signal pr_state, nx_state :state;
signal seg1, seg2, seg3, seg4 : std_logic_vector(6 downto 0);
signal slowClk, anClk : std_logic;
signal doorLEDL, doorLEDR, anodSel: std_logic_vector(3 downto 0);

shared variable opn : integer:=1;
shared variable doorState : integer:=1;
shared variable complete :integer:=0;

component reg Port ( clk : in STD_LOGIC;
                     reset : in std_logic;
                     a : out STD_LOGIC_VECTOR (3 downto 0));
end component;
component  clockDivider Port ( clockIn : in STD_LOGIC;
                     resetClk : in STD_LOGIC;
                     clockOut : out STD_LOGIC);
end component;
component clockDividerAn Port ( clockIn : in STD_LOGIC;
                     resetClk : in STD_LOGIC;
                     clockOut : out STD_LOGIC);
end component;

begin
U0: reg port map(clk,reset,anodSel);
an<=anodSel;
U1: clockDivider port map(clk,reset,slowClk);
U2: clockDividerAn port map(clk,reset,anClk);


Animation: process(anClk, doorLEDL, doorLEDR)
variable i : integer range 0 to 3:=0;
begin
    if rising_edge(anClk) then
        if opn = 0 then        
            if i/=0 and (doorLEDL = "0000" and doorLEDR = "0000") then
                i:=0;
            end if;   
            doorLEDL(i)<='1';
            doorLEdR(i)<='1';
            i := i + 1;
            if doorLEDR /= "1111" then
                complete := 0;
            elsif i = 4 or (doorLEDL = "1111" and doorLEDR = "1111") then
               i := 3;           
               complete := 1;
            end if;
        elsif opn = 1 then
            if i/=3 and (doorLEDL = "1111" and doorLEDR = "1111") then
                i:=3;
            end if; 
            doorLEDL(i) <= '0';
            doorLEDR(i) <= '0';
            i := i - 1;
            if doorLEDR /= "0000" then
                complete := 0;
            elsif i = -1 or (doorLEDL = "0000" and doorLEDR = "0000") then
               i := 0;
               complete := 1;
            end if;
        end if;
    end if;
    doorR<=doorLEDR;
    doorL<=doorLEDL;
end process;

sequential_part: process(slowClk,reset) 
begin 
    if reset = '1'   then
        pr_state <= kat0;
    elsif slowClk'event and slowClk='1' and complete = 1 then
        pr_state <= nx_state;
    end if;
 end process;
   
combinational_part: process(pr_state, sw,upButton,downButton)
variable up : integer:=0;
variable down : integer:=0;
begin         
case pr_state is
    when kat0 => 
        led  <= "10000000";
        seg4 <= "1111001";
        
        if sw(7) = '0' and (sw(0) = '1' or sw(1) = '1' or sw(2) = '1' or sw(3) = '1' or sw(4) = '1' or sw(5) = '1' or sw(6) = '1') and up= 1 then 
            nx_state <= kat1;
                    opn:=0;
        else
            nx_state <= pr_state;
            opn:=1;
        end if;
   when kat1 =>
        led <=  "01000000";
        seg4 <= "0100100";   
   
        if sw(6) = '0' and (sw(0) = '1' or sw(1) = '1' or sw(2) = '1' or sw(3) = '1' or sw(4) = '1' or sw(5) = '1') and up= 1  then
            nx_state <= kat2;
                  opn:=0;
        elsif sw(6)='0' and ( sw (7)='1' )and down = 1 then
            nx_state <= kat0; 
            opn:=0;  
        else
            nx_state <= pr_state;
            opn:=1;
        end if;
    when kat2 =>
        led <=  "00100000";
        seg4 <= "0110000";

        if sw(5) = '0' and (sw(0) = '1' or sw(1) = '1' or sw(2) = '1' or sw(3) = '1' or sw(4) = '1') and up= 1  then 
            nx_state <= kat3;
                    opn:=0;
        elsif sw(5)='0' and ( sw (6)='1' or sw (7)='1' ) and down = 1 then
            nx_state <= kat1; 
            opn:=0; 
        else
            nx_state <= pr_state;
            opn:=1;
        end if;
    when kat3 =>
        led <=  "00010000";
        seg4 <= "0011001"; 
    
        if sw(4) = '0' and (sw(0) = '1' or sw(1) = '1' or sw(2) = '1' or sw(3) = '1') and up= 1  then 
            nx_state <= kat4;
                    opn:=0;
        elsif sw(4)='0' and (sw (5)='1' or sw (6)='1' or sw (7)='1' )  and down = 1 then
            nx_state <= kat2;
            opn:=0;
        else
            nx_state <= pr_state;
            opn:=1;
        end if;
    when kat4 =>
        led <=  "00001000";        
        seg4 <= "0010010";
    
        if sw(3) = '0' and (sw(0) = '1' or sw(1) = '1' or sw(2) = '1') and up= 1  then 
            nx_state <= kat5;
                    opn:=0;
        elsif  sw(3)='0' and (sw (4)='1' or sw (5)='1' or sw (6)='1' or sw (7)='1' ) and down = 1 then
            nx_state <= kat3;
            opn:=0;
        else
            nx_state <= pr_state;
            opn:=1;
        end if;
    when kat5 =>
        led <=  "00000100";
        seg4 <= "0000010";
    
        if sw(2) = '0' and (sw(0) = '1' or sw(1) = '1') and up= 1  then 
            nx_state <= kat6;
                    opn:=0;
        elsif sw(2)='0' and (sw (3)='1' or sw (4)='1' or sw (5)='1' or sw (6)='1' or sw (7)='1' ) and down = 1 then
            nx_state <= kat4;
            opn:=0;
        else
            nx_state <= pr_state;
            opn:=1;
        end if;
    when kat6 =>
        led <=  "00000010";
        seg4 <= "1111000"; 
    
        if sw(1) = '0' and (sw(0) = '1') and up= 1  then 
            nx_state <= kat7;
                    opn:=0;
        elsif sw(1)='0' and (sw (2)='1' or sw (3)='1' or sw (4)='1' or sw (5)='1' or sw (6)='1' or sw (7)='1' )and down = 1 then
            nx_state <= kat5;
            opn:=0;
        else
            nx_state <= pr_state;
            opn:=1;
        end if;
    when kat7 =>
        led <=  "00000001";
        seg4 <= "0000000";  
 
       if sw(0)='0' and (sw(1)='1' or sw (2)='1' or sw (3)='1' or sw (4)='1' or sw (5)='1' or sw (6)='1' or sw (7)='1' ) and down = 1 then
            nx_state <= kat6;
            opn:=0;
       else
            nx_state <= pr_state;
            opn:=1;
       end if;
end case;  
      
    if upButton= '1' AND downButton = '0'  then
        up := 1;
        down := 0;
    elsif upButton= '0' AND downButton = '1' then      
        down := 1;
        up := 0;
    elsif upButton= '1' AND downButton = '1' then      
        down := 0;
        up := 0;            
    end if;
    
    if(opn=1)then
        seg3 <="1001000";--N
        seg2 <="0001100";--P
        seg1 <="1000000";--O
    else
        seg3 <="0010010";--S
        seg2 <="1000111";--L
        seg1 <="1000110";--C
    end if;
    
    case anodSel is
      when "1110" => seg <=seg4;
      when "1101" => seg <=seg3;
      when "1011" => seg <=seg2;
      when others => seg <=seg1;
    end case;
end process;  
end Behavioral;
