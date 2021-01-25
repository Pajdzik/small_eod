# Generated by Django 3.0.3 on 2020-02-21 19:37

import django.core.validators
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('tags', '0003_tagnamespace_prefix'),
    ]

    operations = [
        migrations.AlterField(
            model_name='tag',
            name='name',
            field=models.CharField(max_length=256, verbose_name='Tag'),
        ),
        migrations.AlterField(
            model_name='tagnamespace',
            name='color',
            field=models.CharField(default='000000', max_length=6, validators=[django.core.validators.RegexValidator(code='Non_RGB_hex', message='Field must be hexadecimal RGB color', regex='^(?:[a-f0-9]{6})|(?:[A-F0-9]{6})$')], verbose_name='Color'),
        ),
        migrations.AlterField(
            model_name='tagnamespace',
            name='description',
            field=models.CharField(max_length=256, verbose_name='Description'),
        ),
        migrations.AlterField(
            model_name='tagnamespace',
            name='prefix',
            field=models.CharField(help_text='This namespace will match each tag starting with `prefix`.', max_length=254, verbose_name='Prefix'),
        ),
    ]