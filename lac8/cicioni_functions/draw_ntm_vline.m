function draw_ntm_vline(axArray, ntmTime)

    for a = reshape(axArray,1,[])
        if isgraphics(a)
            hold(a,'on');
            xline(a, ntmTime, '--r', 'LineWidth', 1.5, ...
                'Label', 'NTM onset', ...
                'LabelOrientation','horizontal', ...
                'LabelVerticalAlignment','bottom');
        end
    end

end