library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


package VOTER_PKG is
    function vote(A, B, C: std_logic_vector) return std_logic_vector;
    function vote(A, B, C: std_logic) return std_logic;
    function vote(A, B, C: unsigned) return unsigned;
    function vote(A, B, C: SIGNED) return SIGNED;
end VOTER_PKG;

package body VOTER_PKG is
    -- Standard Logic Vector
    function vote(A, B, C: std_logic_vector) return std_logic_vector is
    begin
        return (A and B) or (A and C) or (B and C);
    end vote;
    
    -- Standard Logic
    function vote(A, B, C: std_logic) return std_logic is
    begin
        return (A and B) or (A and C) or (B and C);
    end vote;
    
    -- Unsigned
    function vote(A, B, C: unsigned) return unsigned is
    begin
        return (A and B) or (A and C) or (B and C);
    end vote;
    
    -- Signed
    function vote(A, B, C: signed) return signed is
    begin
        return (A and B) or (A and C) or (B and C);
    end vote;
end VOTER_PKG;