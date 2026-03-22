local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Enabled = false
local LoopThread

Tab:Toggle({
    Title = "Enable Feature",
    Desc = "วาปไปหาเงินเยอะสุด",
    Value = false,
    Callback = function(v)
        Enabled = v

        if Enabled then
            LoopThread = task.spawn(function()
                while Enabled do
                    local bestTarget = nil
                    local bestMoney = -math.huge

                    -- วนหาเงินมากสุด
                    for _, obj in pairs(workspace:WaitForChild("ActiveBrainrots"):GetChildren()) do
                        pcall(function()
                            local text = obj.LevelBoard.Frame.CurrencyFrame.Earnings.Text.Text
                            
                            -- ดึงตัวเลขจากข้อความ
                            local money = tonumber(string.gsub(text, "%D", "")) or 0
                            
                            if money > bestMoney then
                                bestMoney = money
                                bestTarget = obj
                            end
                        end)
                    end

                    -- ถ้าเจอเป้าหมาย
                    if bestTarget and bestTarget:FindFirstChild("HumanoidRootPart") then
                        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

                        if hrp then
                            -- วาปไป
                            hrp.CFrame = bestTarget.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5)

                            task.wait(0.2)

                            -- กด ProximityPrompt
                            for _, v in pairs(bestTarget:GetDescendants()) do
                                if v:IsA("ProximityPrompt") then
                                    fireproximityprompt(v)
                                end
                            end
                        end
                    end

                    task.wait(0.5) -- ปรับความเร็วได้
                end
            end)
        end
    end
})
