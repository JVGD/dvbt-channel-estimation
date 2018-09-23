library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

package mi_paquete is
    -- For pilots
    type complex12 is record
        re	: std_logic_vector (11 downto 0);
        im	: std_logic_vector (11 downto 0);
    end record;
	
	type complex24 is record
        re	: std_logic_vector (23 downto 0);
        im	: std_logic_vector (23 downto 0);
    end record;
    
    -- For function
    type complex16 is record
        re	: std_logic_vector (15 downto 0);
        im	: std_logic_vector (15 downto 0);
    end record;
    
    -- For function
    type complex17 is record
        re	: std_logic_vector (16 downto 0);
        im	: std_logic_vector (16 downto 0);
    end record;
    
    -- For FSM
    type FSM_estado is (reposo, espera, interpola);
    
    -- Procedure declaration
    function interpolar (
        A : complex12; 
        B : complex12; 
        coef : std_logic_vector(7 downto 0)) 
        return complex12;

end mi_paquete;

package body mi_paquete is

    -- Funcion interpolar de prueba
    function interpolar (
        A : complex12; -- pilot inf
        B : complex12; -- pilot sup
        coef : std_logic_vector(7 downto 0)) 
        return complex12 is 
       
       -- variables
        variable C      : complex12 := (re => (others=>'0'), im => (others=>'0'));
        variable smultA : complex17 := (re => (others=>'0'), im => (others=>'0'));
        variable smultB : complex17 := (re => (others=>'0'), im => (others=>'0'));
        variable coefA  : std_logic_vector(3 downto 0) := (others=>'0');
        variable coefB  : std_logic_vector(3 downto 0) := (others=>'0');
        variable ssum   : complex17 := (re => (others=>'0'), im => (others=>'0'));
        
    begin
        -- coef
        coefB := coef(7 downto 4);      -- coef_sup
        coefA := coef(3 downto 0);      -- coef_inf
        
        -- Mult operation
        -- Concatenamos un cero al principio de los coeficientes
        -- porque los coeficientes son siempre positivos y si empieza
        -- por 1 se interpreta como negativo
        smultA.re := std_logic_vector((signed('0'&coefA) * signed(A.re)));
        smultA.im := std_logic_vector((signed('0'&coefA) * signed(A.im)));
        smultB.re := std_logic_vector((signed('0'&coefB) * signed(B.re)));
        smultB.im := std_logic_vector((signed('0'&coefB) * signed(B.im)));
        
        -- Sum operation
        ssum.re := std_logic_vector(signed(smultA.re) + signed(smultB.re));
        ssum.im := std_logic_vector(signed(smultA.im) + signed(smultB.im));
        
        -- Truncamiento
        C.re := ssum.re(15 downto 4);
        C.im := ssum.im(15 downto 4);
        
        -- Return
        return C;
    end interpolar;
    
    function  divide  (a : UNSIGNED; b : UNSIGNED) return UNSIGNED is
        variable a1 : unsigned(a'length-1 downto 0):=a;
        variable b1 : unsigned(b'length-1 downto 0):=b;
        variable p1 : unsigned(b'length downto 0):= (others => '0');
        variable i : integer:=0;

    begin
        for i in 0 to b'length-1 loop
            p1(b'length-1 downto 1) := p1(b'length-2 downto 0);
            p1(0) := a1(a'length-1);
            a1(a'length-1 downto 1) := a1(a'length-2 downto 0);
            p1 := p1-b1;
            if(p1(b'length-1) ='1') then
                a1(0) :='0';
                p1 := p1+b1;
            else
                a1(0) :='1';
            end if;
        end loop;
        
        return a1;

    end divide;

 
end mi_paquete;
