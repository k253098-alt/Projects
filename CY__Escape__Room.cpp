extern "C" int __cdecl AddFlawlessBonus(int score)
{
    int result;

    __asm
    {
        mov eax, score
        add eax, 50
        mov result, eax
    }

    return result;
}