<?php if ($module->columns[$i]->type_column == "datetime"): ?>

	<div class="input-group">
		
		<input 
		type="text" 
		class="form-control rounded-start datetimepicker" 
		placeholder="YYYY-mm-dd HH:mm"
		id="<?php echo $module->columns[$i]->title_column ?>"  
		name="<?php echo $module->columns[$i]->title_column ?>"
		value="<?php if (!empty($data)): ?><?php echo urldecode($data[$module->columns[$i]->title_column]) ?><?php endif ?>"
		>

		<div class="input-group-text rounded-end">
			<i class="bi bi-calendar-week"></i>
		</div>

	</div>

<?php endif ?>